{
  config,
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
      flakeModules.homeManager."users-${userName}-desktop-core"
    ];
  };

  flake.modules.homeManager."users-${userName}-${suffix}" = {
    imports = with flakeModules.homeManager; [

      calibre
      kitty
      libreoffice
      obsidian
      opencode
      spicetify
      vesktop
    ];
  };
}
