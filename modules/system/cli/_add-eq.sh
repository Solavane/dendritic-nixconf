# add-eq -- turn an AutoEQ/SquigLink parametric EQ file into a PipeWire module.
#
#   add-eq <eq.txt> [hide]
#
#     <eq.txt>  "Preamp: -7.0 dB" followed by
#               "Filter N: ON PK Fc 21 Hz Gain 7.0 dB Q 0.500".
#
#     hide      yes|no (default no). When yes the raw device is hidden from
#               WirePlumber and the module goes to modules/hosts/shared
#               instead of modules/hosts/<hostname>.
#
#     --device <node.name|id>  skip the sink picker
#     --host <name>            write to modules/hosts/<name>
#     --yes                    take the default for every prompt

_add_eq_die() {
  printf 'add-eq: %s\n' "$1" >&2
  return 1
}

_add_eq_help() {
  cat <<'EOF'
add-eq -- turn an AutoEQ/SquigLink parametric EQ file into a PipeWire module.

  add-eq <eq.txt> [hide] [options]

  <eq.txt>  "Preamp: -7.0 dB" followed by
            "Filter N: ON PK Fc 21 Hz Gain 7.0 dB Q 0.500".

  hide      yes|no (default no). When yes the raw device is hidden from
            WirePlumber and the module goes to modules/hosts/shared
            instead of modules/hosts/<hostname>.

  --device <node.name|id>  skip the interactive sink picker
  --host <name>            write to modules/hosts/<name>
  --name <name>            name the EQ (skips the prompt)
  --yes, -y                take the default for every prompt
  --help, -h               this text
EOF
}

# Rewrite an EQ file into exactly what module-parametric-equalizer.c parses.
# That parser is a fixed-width sscanf, so the line order, the integer
# frequency and the field widths all matter.
_add_eq_normalize() {
  awk '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    function warn(m) { printf "add-eq: warning: %s\n", m > "/dev/stderr" }
    function num(s) { return s ~ /^-?[0-9]+(\.[0-9]+)?$/ }

    {
      line = $0
      sub(/\r$/, "", line)
      line = trim(line)
      if (line == "") next

      # Preamp is only read from the very first line, so it has to lead.
      if (line ~ /^Preamp/) {
        if (match(line, /-?[0-9]+(\.[0-9]+)?/)) preamp = substr(line, RSTART, RLENGTH) + 0
        else warn("no gain on the Preamp line, using 0.0")
        saw_preamp = 1
        next
      }

      if (line !~ /^Filter/) { warn("ignoring line " NR ": " line); next }
      if (line !~ /^Filter[ \t]+[0-9]+[ \t]*:/) {
        warn("ignoring malformed filter on line " NR ": " line); next
      }

      body = line
      sub(/^Filter[ \t]+[0-9]+[ \t]*:[ \t]*/, "", body)
      gsub(/[ \t]+/, " ", body)
      n = split(body, f, " ")
      if (n != 10 || f[3] != "Fc" || f[5] != "Hz" || f[6] != "Gain" ||
          f[9] != "Q" || f[8] !~ /^[dD][bB]$/) {
        warn("ignoring malformed filter on line " NR ": " line); next
      }
      if (f[1] != "ON" && f[1] != "OFF") {
        warn("ignoring filter on line " NR ": unknown state " f[1]); next
      }
      if (f[2] != "PK" && f[2] != "LSC" && f[2] != "HSC") {
        warn("ignoring filter on line " NR ": unknown type " f[2]); next
      }
      if (!num(f[4]) || !num(f[7]) || !num(f[10])) {
        warn("ignoring filter on line " NR ": non-numeric Fc/Gain/Q"); next
      }

      cnt++
      st[cnt] = f[1]
      ty[cnt] = f[2]
      fr[cnt] = int(f[4] + 0.5)
      ga[cnt] = f[7] + 0
      q[cnt] = f[10] + 0

      if (fr[cnt] > 99999) {
        warn("filter " cnt ": " fr[cnt] " Hz is wider than the parser field, clamping to 99999")
        fr[cnt] = 99999
      }
      if (f[1] == "ON" && fr[cnt] <= 0) warn("filter " cnt " is ON with no frequency, PipeWire will drop it")
      if (f[1] == "ON" && q[cnt] <= 0) warn("filter " cnt " is ON with Q 0, PipeWire will drop it")
      if (q[cnt] > 99.999) warn("filter " cnt ": Q " q[cnt] " is wider than the parser field, the last digit is lost")
    }

    END {
      if (!saw_preamp) preamp = 0
      if (cnt == 0) { print "add-eq: no usable filter lines in that file" > "/dev/stderr"; exit 1 }

      on = 0
      for (i = 1; i <= cnt; i++) if (st[i] == "ON") on++
      if (on == 0) { print "add-eq: every filter in that file is OFF" > "/dev/stderr"; exit 1 }

      if (preamp > 0)
        warn("preamp is +" preamp " dB; presets usually use a negative preamp to stop the EQ from clipping")

      print "Preamp: " sprintf("%.1f", preamp) " dB"
      for (i = 1; i <= cnt; i++)
        printf "Filter %d: %s %s Fc %d Hz Gain %s dB Q %s\n", i, st[i], ty[i], fr[i], \
               sprintf("%.1f", ga[i]), sprintf("%.3f", q[i])
    }
  ' <"$1"
}

# Is $1 the root of a dendritic flake?
_add_eq_is_root() {
  [ -n "${1:-}" ] || return 1
  [ -f "$1/flake.nix" ] && [ -f "$1/modules/parts.nix" ] && [ -d "$1/modules/hosts" ]
}

# Walk up from $1 looking for the flake root. Echoes the path, returns 1 if it
# never turns up. Must always make progress, or it spins.
_add_eq_walk_up() {
  local dir prev
  dir=${1:-}
  [ -n "$dir" ] || return 1
  dir=${dir%/}
  while :; do
    [ -n "$dir" ] || dir=/
    if _add_eq_is_root "$dir"; then
      printf '%s\n' "$dir"
      return 0
    fi
    [ "$dir" = / ] && return 1
    prev=$dir
    dir=$(dirname -- "$dir" 2>/dev/null) || return 1
    dir=${dir%/}
    # dirname gave us nothing new: stop rather than loop forever
    [ -n "$dir" ] && [ "$dir" != "$prev" ] || return 1
  done
}

# Find the flake root from anywhere. Tries, in order: $DENDROID_ROOT, the
# current directory, the enclosing git repo, then a short list of places a
# flake like this tends to live. Echos the path, returns 1 if nothing matches.
_add_eq_find_root() {
  local base cand

  _add_eq_is_root "${DENDROID_ROOT:-}" && { printf '%s\n' "$DENDROID_ROOT"; return 0; }
  _add_eq_walk_up "$PWD" && return 0

  base=$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null) || base=
  _add_eq_walk_up "$base" && return 0

  for base in \
    "$HOME/Projects" "$HOME/projects" "$HOME/nixconfig" "$HOME/nix" \
    "$HOME/src" "$HOME/code" "$HOME/dotfiles" "$HOME/dev" \
    "$XDG_DATA_HOME/nix" "$HOME/.local/share/nix" "$HOME/.nix-defexpr"
  do
    [ -d "$base" ] || continue
    # the base directory itself
    _add_eq_is_root "$base" && { printf '%s\n' "$base"; return 0; }
    # and its immediate children
    for cand in "$base"/*/; do
      [ -d "$cand" ] || continue
      _add_eq_is_root "${cand%/}" && { printf '%s\n' "${cand%/}"; return 0; }
    done
  done

  return 1
}

# Insert $2 into the bare-identifier list that follows the "# System" marker
# in a host's default.nix, keeping it sorted. Idempotent.
# 0 = ok (inserted, or already there), 1 = write failed,
# 2 = no "# System" block, 3 = block found but the key is not in the result
_add_eq_patch_host() {
  local file=$1 key=$2 tmp
  tmp=$(mktemp) || return 1
  awk -v key="$key" '
    # A module reference: an identifier or a relative path. Deliberately
    # excludes "];", "modules = ...;" and anything with a space.
    function isitem(s) { return s ~ /^[ \t]*[A-Za-z0-9_.:/-]+[ \t]*$/ }
    function flush(   i, j, m, b, ind) {
      if (n == 0) { inblock = 0; return }
      ind = block[1]
      sub(/[^ \t].*$/, "", ind)

      # already imported? leave the block alone
      for (i = 1; i <= n; i++) {
        b = block[i]; gsub(/^[ \t]+|[ \t]+$/, "", b)
        if (b == key) {
          for (j = 1; j <= n; j++) print block[j]
          inblock = 0; n = 0
          return
        }
      }

      m = 0
      for (i = 1; i <= n; i++) {
        b = block[i]; gsub(/^[ \t]+|[ \t]+$/, "", b)
        if (m == 0 && (b "") > (key "")) m = i
      }
      for (i = 1; i <= n; i++) {
        if (i == m) print ind key
        print block[i]
      }
      if (m == 0) print ind key
      inblock = 0; n = 0
    }
    BEGIN { inblock = 0; n = 0; sawblock = 0 }
    /^[ \t]*#[ \t]*System[ \t]*$/ { print; inblock = 1; sawblock = 1; next }
    inblock && /^[ \t]*$/ { flush(); print; next }
    inblock && isitem($0) { block[++n] = $0; next }
    inblock { flush(); print; next }
    { print }
    END { if (inblock) flush(); if (!sawblock) exit 2 }
  ' "$file" >"$tmp"
  local rc=$?
  if [ $rc -eq 2 ]; then
    rm -f "$tmp"
    return 2
  fi
  if [ $rc -ne 0 ]; then
    rm -f "$tmp"
    return 1
  fi

  if ! cmp -s "$file" "$tmp"; then
    cat "$tmp" >"$file" || { rm -f "$tmp"; return 1; }
  fi
  rm -f "$tmp"
  grep -q "^[[:space:]]*$(printf '%s' "$key" | sed 's/[][\\.*^$/]/\\&/g')[[:space:]]*$" \
    "$file" || return 3
  return 0
}

# Slugify a name down to something safe for Nix identifiers, filenames and
# PipeWire node names: lowercase alphanumerics separated by single dashes.
_add_eq_slugify() {
  printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]' |
    sed -e 's/[^a-z0-9]\{1,\}/-/g' -e 's/^-*//' -e 's/-*$//'
}

_add_eq_desc() {
  wpctl inspect "$1" 2>/dev/null |
    sed -n 's/^ *\* *node\.description = "\(.*\)"$/\1/p' | head -1
}

# Print "description<TAB>node.name" for every sink, in PipeWire's own order
# (so the default sink is first).
_add_eq_sinks() {
  local id nm
  while IFS=$'\t' read -r id nm _; do
    [ -n "$id" ] || continue
    printf '%s\t%s\n' "$(_add_eq_desc "$id")" "$nm"
  done < <(wpctl list audio sinks 2>/dev/null)
}

# Resolve a node name (or id) to "description<TAB>node.name". Accepts sources
# too, so a --device that names one is not rejected out of hand.
_add_eq_node() {
  local want=$1 id nm
  local kind
  for kind in sinks sources; do
    while IFS=$'\t' read -r id nm _; do
      [ -n "$id" ] || continue
      if [ "$nm" = "$want" ] || [ "$id" = "$want" ]; then
        printf '%s\t%s\n' "$(_add_eq_desc "$id")" "$nm"
        return 0
      fi
    done < <(wpctl list audio "$kind" 2>/dev/null)
  done
  return 1
}

add-eq() {
  local hide=no device= host= name= assume_yes= reply= pick= desc= def_desc=
  local root host_name target_dir slug base trial eq_out nix_out nix_key dir line l i
  local sinks_txt
  local pos1= pos2= npos=0 rest=

  # Flags and positionals may be interleaved.
  while [ $# -gt 0 ]; do
    case $1 in
      -h|--help) _add_eq_help; return 0 ;;
      --device)
        [ $# -ge 2 ] || { _add_eq_die "--device needs a value"; return 1; }
        case $2 in -*) _add_eq_die "--device needs a value"; return 1 ;; esac
        device=$2; shift 2 ;;
      --host)
        [ $# -ge 2 ] || { _add_eq_die "--host needs a value"; return 1; }
        case $2 in -*) _add_eq_die "--host needs a value"; return 1 ;; esac
        host=$2; shift 2 ;;
      --name)
        [ $# -ge 2 ] || { _add_eq_die "--name needs a value"; return 1; }
        case $2 in -*) _add_eq_die "--name needs a value"; return 1 ;; esac
        name=$2; shift 2 ;;
      --yes|-y) assume_yes=yes; shift ;;
      --) shift; rest=1; break ;;
      -*) _add_eq_die "unknown option $1"; return 1 ;;
      *) npos=$((npos + 1))
         case $npos in
           1) pos1=$1 ;;
           2) pos2=$1 ;;
           *) _add_eq_die "too many arguments: $1"; return 1 ;;
         esac
         shift ;;
    esac
    [ -n "$rest" ] && break
  done
  while [ $# -gt 0 ]; do
    npos=$((npos + 1))
    case $npos in
      1) pos1=$1 ;;
      2) pos2=$1 ;;
      *) _add_eq_die "too many arguments: $1"; return 1 ;;
    esac
    shift
  done

  [ $npos -ge 1 ] || { _add_eq_die "no EQ file given, try 'add-eq --help'"; return 1; }
  eq_file=$pos1
  if [ $npos -ge 2 ] && [ -n "$pos2" ]; then hide=$pos2; fi

  case $hide in
    no|NO|No|false|FALSE|False|0) hide=no ;;
    yes|YES|Yes|true|TRUE|True|1) hide=yes ;;
    *) _add_eq_die "hide must be yes or no, got '$hide'"; return 1 ;;
  esac

  [ -f "$eq_file" ] || { _add_eq_die "no such file: $eq_file"; return 1; }

  # ---- where the flake lives -------------------------------------------------
  if [ -z "${DENDROID_ROOT:-}" ] || ! _add_eq_is_root "$DENDROID_ROOT"; then
    if root=$(_add_eq_find_root); then
      DENDROID_ROOT=$root
      export DENDROID_ROOT
    else
      DENDROID_ROOT=
      unset DENDROID_ROOT
      _add_eq_die "cannot find the dendritic flake root; run add-eq from inside the repo or set DENDROID_ROOT"
      return 1
    fi
  fi
  root=$DENDROID_ROOT

  # ---- which host directory --------------------------------------------------
  if [ -n "$host" ]; then
    [ -d "$root/modules/hosts/$host" ] || { _add_eq_die "no such host: $host"; return 1; }
  elif [ "$hide" = yes ]; then
    host=shared
  else
    host_name=$(hostname 2>/dev/null | tr '[:upper:]' '[:lower:]')
    if [ -d "$root/modules/hosts/$host_name" ]; then
      host=$host_name
    else
      printf 'add-eq: "%s" is not one of your hosts, pass --host:\n' "$host_name" >&2
      for dir in "$root"/modules/hosts/*/; do
        [ -f "$dir/default.nix" ] || continue
        printf '  %s\n' "${dir%/}" | sed 's#.*/##'
      done >&2
      return 1
    fi
  fi

  # ---- which device ----------------------------------------------------------
  command -v wpctl >/dev/null 2>&1 || { _add_eq_die "wpctl not found; is PipeWire running?"; return 1; }

  if [ -z "$device" ]; then
    sinks_txt=$(_add_eq_sinks)
    if [ -z "$sinks_txt" ]; then
      _add_eq_die "PipeWire reports no sinks; plug the device in and try again"
      return 1
    fi
    if [ ! -t 0 ] && [ -z "$assume_yes" ]; then
      _add_eq_die "no tty to prompt on; pass --device <node.name|id>"
      return 1
    fi

    printf 'Which device should this EQ apply to?\n'
    i=1
    while IFS= read -r line; do
      printf '  %2d) %s\n        %s\n' "$i" "${line%%$'\t'*}" "${line#*$'\t'}"
      i=$((i + 1))
    done <<EOF
$sinks_txt
EOF

    if [ -n "$assume_yes" ]; then
      pick=1
    else
      printf 'Enter a number (or a node name): '
      IFS= read -r pick || return 1
      [ -n "$pick" ] || { _add_eq_die "no device chosen"; return 1; }
    fi

    line=
    i=1
    while IFS= read -r l; do
      if [ "$i" = "$pick" ]; then line=$l; break; fi
      i=$((i + 1))
    done <<EOF
$sinks_txt
EOF
    if [ -z "$line" ]; then
      line=$(printf '%s\n' "$sinks_txt" | awk -F'\t' -v p="$pick" '$2 == p { print; exit }')
      [ -n "$line" ] || { _add_eq_die "no such device: $pick"; return 1; }
    fi

    def_desc=${line%%$'\t'*}
    device=${line#*$'\t'}
  else
    line=$(_add_eq_node "$device") ||
      { _add_eq_die "'$device' is not a PipeWire sink or source"; return 1; }
    def_desc=${line%%$'\t'*}
    device=${line#*$'\t'}
  fi

# ---- names -----------------------------------------------------------------
  base=${eq_file##*/}
  base=${base%.txt}
  base=${base%.eq}

  if [ -n "$name" ]; then
    slug=$(_add_eq_slugify "$name")
    [ -n "$slug" ] || { _add_eq_die "cannot make a module name out of '$name'"; return 1; }
  elif [ ! -t 0 ]; then
    slug=$(_add_eq_slugify "$base")
    [ -n "$slug" ] || { _add_eq_die "cannot derive a module name from '$base'"; return 1; }
  else
    slug=$(_add_eq_slugify "$base")
    if [ -z "$slug" ]; then
      _add_eq_die "cannot derive a module name from '$base'; pass --name"
      return 1
    fi
    while :; do
      printf 'Name for this EQ (letters, digits and dashes) [%s]: ' "$slug"
      IFS= read -r reply || return 1
      [ -n "$reply" ] || break
      trial=$(_add_eq_slugify "$reply")
      if [ -z "$trial" ]; then
        printf 'add-eq: %s has no usable characters, try again\n' "$reply"
        continue
      fi
      slug=$trial
      break
    done
  fi

  eq_out=$slug.eq
  nix_out=$slug.nix
  nix_key=equalizer-$slug
  desc="${def_desc:-$slug} EQ"

  target_dir=$root/modules/hosts/$host/equalizer
  mkdir -p "$target_dir" || { _add_eq_die "cannot create $target_dir"; return 1; }

  if [ -e "$target_dir/$nix_out" ] && [ -z "$assume_yes" ]; then
    printf 'add-eq: modules/hosts/%s/equalizer/%s already exists. Overwrite? [y/N] ' "$host" "$nix_out"
    IFS= read -r reply || return 1
    case $reply in [yY]|[yY][eE][sS]) ;; *) printf 'add-eq: left it alone\n'; return 1 ;; esac
  fi

  # ---- the eq file -----------------------------------------------------------
  _add_eq_normalize "$eq_file" >"$target_dir/$eq_out".tmp || { rm -f "$target_dir/$eq_out".tmp; return 1; }
  mv "$target_dir/$eq_out".tmp "$target_dir/$eq_out" || return 1

  # ---- the module ------------------------------------------------------------
  {
    printf '# Generated by add-eq from %s.\n' "${eq_file##*/}"
    printf '{\n'
    printf '  flake.modules.nixos.%s = {\n' "$nix_key"
    printf '    services.pipewire.extraConfig.pipewire."99-eq-%s" = {\n' "$slug"
    printf '      "context.modules" = [\n'
    printf '        {\n'
    printf '          name = "libpipewire-module-parametric-equalizer";\n'
    printf '          args = {\n'
    printf '            "equalizer.filepath" = "${./%s}";\n' "$eq_out"
    printf '            "equalizer.description" = "%s";\n' "$desc"
    printf '            "capture.props" = {\n'
    printf '              "media.class" = "Audio/Sink";\n'
    printf '              "node.name" = "effect_input.eq_%s";\n' "$slug"
    printf '            };\n'
    printf '            "playback.props" = {\n'
    printf '              "node.target" = "%s";\n' "$device"
    printf '            };\n'
    printf '          };\n'
    printf '        }\n'
    printf '      ];\n'
    printf '    };\n'
    if [ "$hide" = yes ]; then
      printf '\n'
      printf '    services.pipewire.wireplumber.extraConfig."10-hide-%s" = {\n' "$slug"
      printf '      "monitor.alsa.rules" = [\n'
      printf '        {\n'
      printf '          matches = [\n'
      printf '            { "node.name" = "%s"; }\n' "$device"
      printf '          ];\n'
      printf '          actions.update-props."node.hidden" = true;\n'
      printf '        }\n'
      printf '      ];\n'
      printf '    };\n'
    fi
    printf '  };\n'
    printf '}\n'
  } >"$target_dir/$nix_out" || return 1

  # ---- hook it up ------------------------------------------------------------
  if [ "$host" = shared ]; then
    local hooked=no hname
    for dir in "$root"/modules/hosts/*/; do
      [ -f "$dir/default.nix" ] || continue
      hname=${dir%/}
      hname=${hname##*/}
      _add_eq_patch_host "$dir/default.nix" "$nix_key"
      case $? in
        0) printf 'add-eq: %s imports %s\n' "$hname" "$nix_key"; hooked=yes ;;
        2) _add_eq_die "modules/hosts/$hname/default.nix has no '# System' block to add $nix_key to"; return 1 ;;
        3) _add_eq_die "could not add $nix_key to modules/hosts/$hname/default.nix"; return 1 ;;
        *) _add_eq_die "could not patch modules/hosts/$hname/default.nix"; return 1 ;;
      esac
    done
    [ "$hooked" = yes ] || { _add_eq_die "found no host to import $nix_key into"; return 1; }
  else
    _add_eq_patch_host "$root/modules/hosts/$host/default.nix" "$nix_key"
    case $? in
      0) printf 'add-eq: %s imports %s\n' "$host" "$nix_key" ;;
      2) _add_eq_die "modules/hosts/$host/default.nix has no '# System' block to add $nix_key to"; return 1 ;;
      3) _add_eq_die "could not add $nix_key to modules/hosts/$host/default.nix"; return 1 ;;
      *) _add_eq_die "could not patch modules/hosts/$host/default.nix"; return 1 ;;
    esac
  fi

  printf 'add-eq: wrote modules/hosts/%s/equalizer/%s\n' "$host" "$eq_out"
  printf 'add-eq: wrote modules/hosts/%s/equalizer/%s\n' "$host" "$nix_out"
  printf 'add-eq: target %s, hide %s\n' "$device" "$hide"
}
