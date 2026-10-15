{
  flake.modules.homeManager.roomeqwizard = { pkgs, ... }: {
    home.packages = with pkgs; [
      roomeqwizard
    ];
  };
}