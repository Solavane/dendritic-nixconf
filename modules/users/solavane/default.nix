{
  config,
  ...
}:
let
  userName = baseNameOf (toString ./.);
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

  flake.modules.homeManager."users-${userName}" = {
    home.username = "${userName}";
    home.homeDirectory = "/home/${userName}";
    home.stateVersion = "25.11";

    imports = with flakeModules.homeManager; [
      cli
      syncthing
    ];
  };
}
