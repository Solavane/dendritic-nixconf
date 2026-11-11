{
  config,
  lib,
  ...
}:
let
  userName = baseNameOf (toString ./.);
  persistenceRoot = config.vars.persistenceRoot;
  flakeModules = config.flake.modules;
in
{
  # Always safe to add. Linux user + minimal home
  flake.modules.nixos."users-${userName}" = { config, pkgs, ... }: {
    users.users.${userName} = {
      isNormalUser = true;
      extraGroups = [ "audio" "wheel" "networkmanager" ];
      shell = pkgs.zsh;

      hashedPasswordFile = lib.mkIf
        (config.environment.persistence."/persistent".enable or false)
        "${persistenceRoot}/secrets/${userName}.password";
    };

    home-manager.users.${userName}.imports = [
      flakeModules.homeManager."users-${userName}"
    ];
  };

  flake.modules.homeManager."users-${userName}" = {
    home.persistence."/persistent".enable = lib.mkDefault false;
    home.username = "${userName}";
    home.homeDirectory = "/home/${userName}";
    home.stateVersion = "25.11";

    imports = with flakeModules.homeManager; [
      cli
      mango-shortcuts
      syncthing
    ];

    programs.git = {
      enable = true;
      settings.user = {
        name = "solavane";
        email = "solavane@proton.me";
      };
    };
  };
}
