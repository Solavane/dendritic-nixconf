{
  flake.modules.homeManager.libresprite = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "libresprite" ];

    home.persistence."/persistent" = {
      directories = [
        ".config/libresprite"
      ];
    };

    home.packages = with pkgs; [
      libresprite
    ];
  };
}
