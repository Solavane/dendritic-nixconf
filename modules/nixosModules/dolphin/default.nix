{
  flake.modules.homeManager.dolphin = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "dolphin" ];

    home.persistence."/persistent".directories = [
      ".local/share/dophin"
    ];

    home.persistence."/persistent".files = [
      ".local/state/dophinstaterc"
    ];

    home.packages = [
      pkgs.kdePackages.dolphin
    ];
  };
}
