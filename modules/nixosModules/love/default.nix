{
  flake.modules.homeManager.love = { pkgs, ... }: {
    home.persistence."/persistent".directories = [
      ".local/share/love"
    ];

    home.packages = [ pkgs.love ];
  };
}