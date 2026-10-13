{
  flake.modules.homeManager.syncthing =
    {
      config,
      lib,
      osConfig,
      ...
    }:
    let
      cfg = config.modules.homeManager.syncthing;
      userName = config.home.username;

      devices = import ../../users/${userName}/syncthing/_devices.nix;
      folders = import ../../users/${userName}/syncthing/_folders.nix {
        home = config.home.homeDirectory;
      };

      allDevices = builtins.attrNames devices;
      hubDevices = lib.filter (name: devices.${name}.hub or false) allDevices;

      # The device representing this machine, matched by hostname.
      selfDevice = lib.findFirst (name: (devices.${name}.hostname or null) == osConfig.networking.hostName) null allDevices;

      peers = if cfg.devices == "all" then allDevices else cfg.devices;
      folderSelection =
        if cfg.folders == "all" then
          lib.genAttrs (builtins.attrNames folders) (_: "all")
        else
          cfg.folders;
      explicitFolderDevices = lib.concatLists (
        lib.attrValues (lib.filterAttrs (_: spec: spec != "all") folderSelection)
      );

      # Peers, hubs (auto-joined) and any device explicitly referenced by a folder.
      connected = lib.unique (lib.subtractLists [ selfDevice ] (peers ++ hubDevices ++ explicitFolderDevices));

      resolveDevices =
        spec: if spec == "all" then connected else lib.unique (lib.subtractLists [ selfDevice ] (spec ++ hubDevices));

      settingsDevices = lib.genAttrs connected (name: { inherit (devices.${name}) id; });

      settingsFolders = lib.mapAttrs (
        name: spec:
        {
          inherit (folders.${name}) path;
          devices = resolveDevices spec;
        }
        // lib.optionalAttrs (folders.${name} ? ignorePatterns) {
          inherit (folders.${name}) ignorePatterns;
        }
      ) folderSelection;
    in
    {
      options.modules.homeManager.syncthing = {
        enable = lib.mkEnableOption "Syncthing file synchronization";

        devices = lib.mkOption {
          type = lib.types.either (lib.types.enum [ "all" ]) (lib.types.listOf lib.types.str);
          default = [ ];
          description = ''
            Devices this machine connects to. Hub devices (from the user catalog)
            are added automatically, so only extra peer devices need to be listed.
            Use "all" to connect to every device in the catalog.
          '';
        };

        folders = lib.mkOption {
          type = lib.types.either (lib.types.enum [ "all" ]) (
            lib.types.attrsOf (lib.types.either (lib.types.enum [ "all" ]) (lib.types.listOf lib.types.str))
          );
          default = { };
          description = ''
            Folders to serve, as an attribute set mapping a catalog folder name
            to the devices to share it with. A value of "all" shares with every
            connected device; an empty list shares it with hub devices only.
            Use the string "all" to enable every catalog folder.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        services.syncthing = {
          enable = true;

          settings = {
            devices = settingsDevices;
            folders = settingsFolders;
          };
        };
      };
    };
}
