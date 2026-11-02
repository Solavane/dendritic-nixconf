{
  flake.modules.homeManager.roomeqwizard = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "roomeqwizard" ];

    home.persistence."/persistent".directories = [
      "REW"
    ];

    home.packages = with pkgs; [
      roomeqwizard
    ];
  };
}