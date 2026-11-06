{
  flake.modules.homeManager.darktable = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "darktable" ];

    home.persistence."/persistent" = {
      directories = [
        ".config/darktable"
      ];
    };

    home.packages = with pkgs; [
      darktable
    ];
  };
}
