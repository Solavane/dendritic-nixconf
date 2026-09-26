{ 
  config, 
  lib,
  ... 
}:
let
  userName = "solavane";
  flakeModules = config.flake.modules;
in
{
  # Always safe to add. Linux user + minimal home
  flake.modules.nixos."users-${userName}" = { pkgs, ... }: {
    users.users.${userName} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.zsh;
    };

    home-manager.users.${userName}.imports = [
      flakeModules.homeManager."users-${userName}"
    ];
  };
  
  # Opt-in for desktop usage
  flake.modules.nixos."users-${userName}-desktop" = {
    home-manager.sharedModules = [
      flakeModules.homeManager."users-${userName}-desktop"
    ];
  };
  
  flake.modules.homeManager."users-${userName}" = {
    home.username = "${userName}";
    home.homeDirectory = "/home/${userName}";
    home.stateVersion = "25.11";
    
    imports = with flakeModules.homeManager; [
      cli
    ];
  };

  flake.modules.homeManager."users-${userName}-desktop" = {
    imports = with flakeModules.homeManager; [
      blender
      faugus
      keepassxc
      kitty
      obsidian
      opencode
      prismlauncher
      prusa-slicer
      spicetify
      syncthing
      vesktop
      zen-browser
    ];
    
    modules.homeManager.prismlauncher.jdk = lib.mkDefault [ "jdk25" "jdk21" ];
  };
}
