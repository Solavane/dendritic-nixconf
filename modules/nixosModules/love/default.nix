{
  flake.modules.homeManager.love = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "love" ];

    home.persistence."/persistent".directories = [
      ".local/share/love"
    ];

    home.packages = [ pkgs.love ];
  };
}