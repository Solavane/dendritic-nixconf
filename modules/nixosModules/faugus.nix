{
  flake.modules.homeManager.faugus = { pkgs, ... }: {
    home.packages = with pkgs; [
      faugus-launcher
    ];
  };
}
