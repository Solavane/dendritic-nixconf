{
  flake.modules.homeManager.love = { pkgs, ... }: {
    home.packages = [ pkgs.love ];
  };
}