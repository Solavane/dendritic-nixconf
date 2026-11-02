{
  config,
  lib,
  ...
}:
let
  vars = config.vars;
  repoRoot = ../../..;
  hostsDirectory = repoRoot + "/${vars.hostsDirectory}";

  hostNames = lib.sort (a: b: a < b) (
    builtins.attrNames (
      lib.filterAttrs (
        name: type:
        type == "directory"
        && name != "iso"
        && builtins.pathExists (hostsDirectory + "/${name}/default.nix")
        && lib.hasInfix "disko" (builtins.readFile (hostsDirectory + "/${name}/default.nix"))
      ) (builtins.readDir hostsDirectory)
    )
  );
in
{
  flake.modules.nixos.installer =
    {
      pkgs,
      lib,
      ...
    }:
    let
      hostItems = lib.concatMapStringsSep "\n" (
        name:
        "  - id: ${builtins.toJSON name}\n"
        + "    packages: []\n"
        + "    name: ${builtins.toJSON name}\n"
        + "    description: ${builtins.toJSON "Install the existing ${name} host from the repository."}"
      ) hostNames;

      hostConf = pkgs.writeText "calamares-host.conf" ''
        mode: required
        method: legacy
        labels:
          step: "Host"
        items:
        ${hostItems}
          - id: "__new__"
            packages: []
            name: "Create a new host"
            description: "Detect this machine and create a new host in the repository."
      '';

      moduleMain = pkgs.writeText "flake-installer-main.py" (
        builtins.replaceStrings
          [
            "@repoUrl@"
            "@repoBranch@"
            "@userName@"
            "@configLocation@"
            "@persistenceRoot@"
            "@hostsDirectory@"
          ]
          [
            vars.repoUrl
            vars.repoBranch
            vars.userName
            vars.configLocation
            vars.persistenceRoot
            vars.hostsDirectory
          ]
          (builtins.readFile ./calamares/main.py)
      );

      listDisks = pkgs.writeText "calamares-list-disks.py" (
        builtins.replaceStrings
          [ "@lsblk@" ]
          [ "${pkgs.util-linux}/bin/lsblk" ]
          (builtins.readFile ./calamares/list-disks.py)
      );

      customExtensions = pkgs.runCommand "calamares-nixos-extensions-solavane" { } ''
        mkdir -p $out
        cp -r ${pkgs.calamares-nixos-extensions}/. $out/
        chmod -R u+w $out
        install -Dm644 ${./calamares/settings.conf} $out/etc/calamares/settings.conf
        install -Dm644 ${hostConf} $out/etc/calamares/modules/host.conf
        install -Dm644 ${./calamares/users.conf} $out/etc/calamares/modules/users.conf
        install -Dm755 ${moduleMain} $out/lib/calamares/modules/flake-installer/main.py
        install -Dm644 ${./calamares/module.desc} $out/lib/calamares/modules/flake-installer/module.desc
        substituteInPlace $out/etc/calamares/settings.conf --replace-fail '@out@' "$out"
      '';

      calamares = pkgs.calamares.override {
        extraWrapperArgs = [
          "--prefix XDG_DATA_DIRS : ${customExtensions}/share"
          "--prefix XDG_CONFIG_DIRS : /run/calamares-installer:${customExtensions}/etc"
          "--add-flag --xdg-config"
        ];
      };

      rootLauncher = pkgs.writeShellScriptBin "calamares-installer-root" ''
        set -eu

        export HOME=/root
        export PATH="/run/current-system/sw/bin:/run/current-system/sw/sbin:${lib.makeBinPath [
          pkgs.python3
          pkgs.util-linux
          pkgs.git
          pkgs.disko
          pkgs.mkpasswd
          pkgs.zenity
          calamares
        ]}:''${PATH:-}"

        if [ -n "''${1-}" ]; then export WAYLAND_DISPLAY="$1"; fi
        if [ -n "''${2-}" ]; then export XDG_RUNTIME_DIR="$2"; fi
        if [ -n "''${3-}" ]; then export DISPLAY="$3"; fi
        if [ -n "''${4-}" ]; then export XAUTHORITY="$4"; fi

        export QT_QPA_PLATFORM="wayland;xcb"

        runtime=/run/calamares-installer
        rm -rf "$runtime"
        mkdir -p "$runtime/calamares/modules"

        if ! ${pkgs.python3}/bin/python3 ${listDisks} "$runtime/calamares/modules/disk.conf" >"$runtime/prepare.log" 2>&1; then
          ${pkgs.zenity}/bin/zenity --error --title="Installer" --text="No installable disks were found. See $runtime/prepare.log."
          exit 1
        fi

        exec ${calamares}/bin/calamares
      '';

      sessionLauncher = pkgs.writeShellScriptBin "calamares-installer" ''
        set -eu

        pkexec_path=/run/wrappers/bin/pkexec
        if [ ! -x "$pkexec_path" ]; then
          pkexec_path=pkexec
        fi

        exec "$pkexec_path" ${rootLauncher}/bin/calamares-installer-root \
          "''${WAYLAND_DISPLAY:-}" \
          "''${XDG_RUNTIME_DIR:-}" \
          "''${DISPLAY:-}" \
          "''${XAUTHORITY:-}"
      '';
    in
    {
      environment.systemPackages = [
        sessionLauncher
        pkgs.glibcLocales
      ];

      i18n.supportedLocales = [ "all" ];

      security.polkit = {
        enablePkexecWrapper = true;
        extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (subject.isInGroup("wheel")) {
              return polkit.Result.YES;
            }
          });
        '';
      };

      home-manager.users.${vars.userName}.wayland.windowManager.mango.autostart_sh = lib.mkAfter ''
        ${sessionLauncher}/bin/calamares-installer &
      '';
    };
}
