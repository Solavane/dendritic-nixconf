{
  flake.modules.homeManager.dolphin = { pkgs, ... }: {
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
