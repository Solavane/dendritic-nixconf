{
  flake.modules.homeManager.prusa-slicer = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "prusa-slicer" ];

    home.persistence."/persistent".directories = [
      ".config/PrusaSlicer"
      ".local/share/prusa-slicer"
    ];

    home.packages = with pkgs; [
      prusa-slicer
    ];
  };
}
