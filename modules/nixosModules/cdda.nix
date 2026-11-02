{
  flake.modules.homeManager.cdda = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "cdda" ];

    home.packages = with pkgs; [
      cataclysm-dda
    ];
  };
}
