{
  flake.modules.homeManager.roomeqwizard = { pkgs, ... }: {
    home.persistence."/persistent".directories = [
      "REW"
    ];

    home.packages = with pkgs; [
      roomeqwizard
    ];
  };
}