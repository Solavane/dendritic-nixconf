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
      extraGroups = [ "audio" "wheel" "networkmanager" ];
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

  flake.modules.nixos."users-${userName}-pc" = {
    home-manager.sharedModules = [
      flakeModules.homeManager."users-${userName}-pc"
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
      keepassxc
      kitty
      love
      obsidian
      opencode
      prusa-slicer
      spicetify
      syncthing
      vesktop
      zen-browser
    ];

    modules.homeManager.prismlauncher.jdk = lib.mkDefault [ "jdk25" "jdk21" ];
    modules.homeManager.zen-browser = {
      allowedCookieSites = [
        "https://google.com"
        "https://duckduckgo.com"
        "https://github.com"
        "https://spotify.com"
        "https://twitch.tv"
        "https://youtube.com"
        "https://oraclecloud.com"
      ];
      uBlockBlocklist = [
        "www.youtube.com##ytd-rich-section-renderer.ytd-rich-grid-renderer.style-scope"
        "dashboard.twitch.tv##.cmdNOM.Layout-sc-1xcs6mc-0"
      ];
    };
  };

  flake.modules.homeManager."users-${userName}-pc" = {
    imports = with flakeModules.homeManager; [
      blender
      faugus
      fl-studio
      prismlauncher

      flatpak
    ];
  };
}
