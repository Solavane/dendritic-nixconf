{
  flake.modules.homeManager.cdda = { pkgs, ... }: {
    home.packages = with pkgs; [
      cataclysm-dda
    ];
  };
}
