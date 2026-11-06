{
  flake.modules.homeManager.krita = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "krita" ];

    home.persistence."/persistent" = {
      directories = [
        ".local/share/krita"
      ];
      files = [
        ".config/kritarc"
        ".config/kritadisplayrc"
      ];
    };

    home.packages = with pkgs; [
      krita
    ];
  };
}
