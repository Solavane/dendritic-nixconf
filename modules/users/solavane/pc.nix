{
  config,
  lib,
  ...
}:
let
  userName = baseNameOf (toString ./.);
  suffix = builtins.replaceStrings [ ".nix" ] [ "" ] (
    baseNameOf (builtins.unsafeGetAttrPos "suffix" { suffix = null; }).file
  );
  flakeModules = config.flake.modules;
in
{
  flake.modules.nixos."users-${userName}-${suffix}" = {
    home-manager.sharedModules = [
      flakeModules.homeManager."users-${userName}-${suffix}"
    ];
  };

  flake.modules.homeManager."users-${userName}-${suffix}" = {
    imports = with flakeModules.homeManager; [
      blender
      davinci-resolve
      faugus
      fl-studio
      obs
      prismlauncher

      flatpak
    ];

    modules.homeManager.prismlauncher.jdk = lib.mkDefault [ "jdk25" "jdk21" ];

    modules.homeManager.syncthing = {
      enable = true;
      devices = [ "pixel-8-pro" ];
      folders = "all";
    };
  };
}
