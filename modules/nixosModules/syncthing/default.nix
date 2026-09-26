{
  flake.modules.homeManager.syncthing = { config, lib, ... }: 
  let
    devicesFile = ../../users/${config.home.username}/_syncthing-devices.nix;
  in
  {
    services.syncthing = {
      enable = true;

      settings = {
        devices = if builtins.pathExists devicesFile
          then import devicesFile
          else throw "syncthing-devices.nix not found at ${toString devicesFile}";
        folders = {
          secrets = {
            path = "${config.home.homeDirectory}/.secrets/sync";
            devices = lib.attrNames (lib.optionalAttrs (builtins.pathExists devicesFile) (import devicesFile));
          };
          obsidian = {
            path = "${config.home.homeDirectory}/Documents/Obsidian";
            devices = lib.attrNames (lib.optionalAttrs (builtins.pathExists devicesFile) (import devicesFile));
            ignorePatterns = [ #Ignores syncing settings due to issues on phone
              ".obsidian"
            ];
          };
        };
      };
    }; 
  };
}
