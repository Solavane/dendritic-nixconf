{
  flake.modules.homeManager.fl-studio =
    { config, lib, pkgs, ... }:
    let
      cfg = config.modules.homeManager.fl-studio;

      wine = pkgs.wineWow64Packages.staging;

      # Upstream WineASIO 1.3.0 calls mlockall(MCL_FUTURE) from ASIO::init()
      # and ignores the result. MCL_FUTURE charges every *later* mmap in the
      # process against RLIMIT_MEMLOCK, and systemd 261 hands GUI sessions an
      # 8 MiB cap that logind.conf can no longer override (DefaultLimit* is not a
      # recognised key there any more, and it is applied to session scopes and
      # user@.service alike). Wine blows past 8 MiB almost immediately, mmap then
      # fails with EAGAIN, and PipeWire's JACK client deadlocks on a futex inside
      # jack_client_open() -- FL Studio spins at 100% CPU and never finishes
      # starting. The call is dropped: the ASIO thread gets its real-time
      # priority from rtkit (security.rtkit.enable) rather than from pinning the
      # whole address space.
      wineasio = pkgs.wineasio.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace asio.c \
            --replace-fail 'mlockall(MCL_FUTURE);' \
              '/* mlockall(MCL_FUTURE) dropped: it deadlocks PipeWire under a low RLIMIT_MEMLOCK. */'
        '';
      });

      # WineASIO ships two files per arch: a "fake" Windows DLL used only so the
      # registry can name a module, and the real native driver as a .dll.so.
      # Wine strips the arch suffix when resolving fake DLLs, so the real
      # driver is copied in under both names to stay resolvable.
      wineasioNative = "${wineasio}/lib/wine/x86_64-unix/wineasio64.dll.so";
      wineasioFake = "${wineasio}/lib/wine/x86_64-windows/wineasio64.dll";
      wineasioClsId = "48D0C522-BFCC-45CC-8B84-17F25F33E6E8";

      # PipeWire's JACK implementation must win over any other libjack.so.0,
      # otherwise WineASIO's dlopen picks up a server that is not running.
      audioLibPath = lib.makeSearchPathOutput "lib" "lib" [
        pkgs.pipewire.jack
        pkgs.alsa-lib
      ];

      # Idempotent: installs and registers WineASIO into the prefix, and is
      # cheap enough (a single grep) to run on every launch as a self-heal.
      wineasioSetup = pkgs.writeShellApplication {
        name = "fl-studio-wineasio-setup";
        runtimeInputs = [ wine ];
        text = ''
          export WINEPREFIX=${lib.escapeShellArg cfg.prefix}
          export WINEARCH=win64

          sysdir="$WINEPREFIX/drive_c/windows/system32"
          stamp="$WINEPREFIX/.fl-studio-wineasio"

          # Ask wineserver rather than grepping system.reg: "wine reg add"
          # only updates the server's in-memory registry, and system.reg is
          # flushed lazily, so a grep straight afterwards races and reports a
          # perfectly good registration as missing. The output is captured
          # instead of piped into grep -q: grep would exit on the first match,
          # SIGPIPE would kill wine, and errexit/pipefail would then read a
          # successful check as a failure.
          registered() {
            local out
            out="$(wine reg query "HKCR\\CLSID\\{${wineasioClsId}}\\InprocServer32" /ve 2>/dev/null)" || return 1
            case "$out" in *wineasio64.dll.so*) return 0 ;; *) return 1 ;; esac
          }

          if [ ! -d "$sysdir" ]; then
            echo "Initialising Wine prefix at $WINEPREFIX..."
            wineboot --init
            for _ in $(seq 1 120); do
              [ -d "$sysdir" ] && break
              sleep 0.5
            done
          fi

          if [ ! -d "$sysdir" ]; then
            echo "Wine prefix at $WINEPREFIX failed to initialise" >&2
            exit 1
          fi

          if [ -f "$stamp" ] \
            && [ "$(cat "$stamp")" = ${lib.escapeShellArg wineasioNative} ] \
            && registered; then
            exit 0
          fi

          echo "Installing and registering WineASIO in $WINEPREFIX..."

          install -Dm755 ${lib.escapeShellArg wineasioNative} "$sysdir/wineasio64.dll.so"
          # Wine's fake-module lookup drops the arch suffix, so alias it too.
          ln -sfn wineasio64.dll.so "$sysdir/wineasio.dll.so"
          # The registry names "wineasio64.dll"; keep Wine's own stub so it is
          # not mistaken for a native driver.
          ln -sfn ${lib.escapeShellArg wineasioFake} "$sysdir/wineasio64.dll"

          wine regsvr32 ${lib.escapeShellArg wineasioNative} >/dev/null 2>&1

          # regsvr32 records InprocServer32 as the bare "wineasio64.dll", which
          # Wine can only satisfy through a Wine DLL override. Point it at the
          # native ELF so it loads without any WINEDLLPATH juggling.
          wine reg add \
            "HKCR\CLSID\{${wineasioClsId}}\InprocServer32" \
            /ve /t REG_SZ /d "C:\windows\system32\wineasio64.dll.so" /f >/dev/null
          wine reg add \
            "HKCR\CLSID\{${wineasioClsId}}\InprocServer32" \
            /v ThreadingModel /t REG_SZ /d Apartment /f >/dev/null

          if ! registered; then
            echo "WineASIO registration did not stick in $WINEPREFIX" >&2
            exit 1
          fi

          printf '%s\n' ${lib.escapeShellArg wineasioNative} >"$stamp"
        '';
      };

      # Replaces the old global WINEPREFIX: only FL Studio and its helpers see
      # any of this.
      flStudio = pkgs.writeShellApplication {
        name = "fl-studio";
        runtimeInputs = [ wine pkgs.coreutils ];
        text = ''
          export WINEPREFIX=${lib.escapeShellArg cfg.prefix}
          export WINEARCH=win64

          # Opportunistic: if the session ever ships with a generous memlock
          # hard limit, use all of it for PipeWire's own locked buffers. The
          # deadlock itself is fixed in the patched wineasio above, so this is
          # a nicety, not the fix -- and it fails harmlessly on the 8 MiB cap
          # systemd 261 gives GUI sessions.
          ulimit -l unlimited 2>/dev/null || true

          old_ld_path="$(printenv LD_LIBRARY_PATH || true)"
          if [ -n "$old_ld_path" ]; then
            export LD_LIBRARY_PATH=${lib.escapeShellArg (audioLibPath + ":")}"$old_ld_path"
          else
            export LD_LIBRARY_PATH=${lib.escapeShellArg audioLibPath}
          fi

          ${wineasioSetup}/bin/fl-studio-wineasio-setup

          image_line_dir="$WINEPREFIX/drive_c/Program Files/Image-Line"
          shopt -s nullglob
          candidates=("$image_line_dir"/FL\ Studio*/FL64.exe "$image_line_dir"/FL\ Studio*/FL.exe)
          shopt -u nullglob

          if [ "''${#candidates[@]}" -eq 0 ]; then
            echo "FL Studio is not installed in $WINEPREFIX." >&2
            echo "Install it once from the Image-Line installer, then use 'fl-studio'." >&2
            exit 1
          fi

          exec wine "''${candidates[0]}" "$@"
        '';
      };

      # Runs any Windows program inside FL Studio's prefix, so plugin
      # installers land where FL can see them:
      #   fl-studio-wine ~/Downloads/SomePlugin-Setup.exe
      # A bare `wine` would use ~/.wine now that the global WINEPREFIX is gone.
      flStudioWine = pkgs.writeShellApplication {
        name = "fl-studio-wine";
        runtimeInputs = [ wine ];
        text = ''
          export WINEPREFIX=${lib.escapeShellArg cfg.prefix}
          export WINEARCH=win64
          exec wine "$@"
        '';
      };

    in
    {
      options.modules.homeManager.fl-studio = {
        prefix = lib.mkOption {
          type = lib.types.str;
          default = "${config.home.homeDirectory}/.wine-flstudio";
          description = "Wine prefix dedicated to FL Studio.";
        };
      };

      # The old WINEPREFIX/WINEARCH/WINEDLLPATH session variables leaked into
      # every Wine application on the system, and a stray WINEDLLPATH pointing
      # at lib/wine is what broke WineASIO in the first place. They now live
      # only inside the fl-studio wrappers.
      config = {
        home.packages = [
          flStudio
          flStudioWine
          wineasioSetup
          wineasio
          wine
          pkgs.winetricks
          pkgs.yabridge
          pkgs.yabridgectl
        ];

        home.activation.flStudioWineAsio = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          $DRY_RUN_CMD ${wineasioSetup}/bin/fl-studio-wineasio-setup
        '';

        # Wine's start-menu sync drops its own .desktop files into
        # ~/.local/share/applications. They exec FL64.exe directly, so they skip
        # the wrapper entirely -- no memlock raise, no PipeWire libjack, no
        # self-heal -- and FL Studio then hangs on the ASIO deadlock. Disable
        # them (reversibly) so the launcher only offers the managed entry.
        home.activation.flStudioLauncherCleanup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          for entry in \
            "$HOME/.local/share/applications/wine-protocol-flstudio.desktop" \
            "$HOME/.local/share/applications/wine/Programs/Image-Line/FL Studio 2026.desktop"
          do
            if [ -e "$entry" ]; then
              $DRY_RUN_CMD mv -f "$entry" "$entry.disabled"
              echo "Disabled Wine-generated FL Studio launcher: $entry"
            fi
          done
        '';

        # Uses the absolute store path rather than bare "fl-studio" because a
        # GUI session's PATH does not necessarily include the Home Manager
        # profile's bin directory.
        xdg.desktopEntries."fl-studio" = {
          name = "FL Studio";
          genericName = "Digital Audio Workstation";
          comment = "Sequence, record and mix music";
          exec = "${flStudio}/bin/fl-studio %U";
          icon = "1010_FL64.0";
          terminal = false;
          type = "Application";
          categories = [
            "AudioVideo"
            "Audio"
            "Midi"
          ];
          mimeType = [ "x-scheme-handler/flstudio" ];
        };

        home.activation.flStudioYabridge = lib.hm.dag.entryAfter [ "flStudioWineAsio" ] ''
          export WINEPREFIX=${lib.escapeShellArg cfg.prefix}
          $DRY_RUN_CMD ${pkgs.yabridgectl}/bin/yabridgectl sync || true
        '';
      };
    };
}
