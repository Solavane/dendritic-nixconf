{
  flake.modules.homeManager.prusa-slicer = { pkgs, ... }: {
    home.packages = with pkgs; [
      prusa-slicer
    ];
  };
}
