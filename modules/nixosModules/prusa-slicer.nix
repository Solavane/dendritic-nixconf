{
  flake.modules.homeManager.prusa-slicer = { pkgs, ... }: {
    home.persistence."/persistent".directories = [
      ".config/PrusaSlicer"
      ".local/share/prusa-slicer"
    ];

    home.packages = with pkgs; [
      prusa-slicer
    ];
  };
}
