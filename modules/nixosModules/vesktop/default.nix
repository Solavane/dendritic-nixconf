{
  flake.modules.homeManager.vesktop = { pkgs, ... }: {
    config.home.packages = [
      pkgs.vesktop
    ];
  };
}
