{
  flake.modules.homeManager.inkscape = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "inkscape" ];

    home.persistence."/persistent" = {
      directories = [
        ".config/inkscape"
      ];
    };

    home.packages = with pkgs; [
      inkscape
    ];
  };
}
