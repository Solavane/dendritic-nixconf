{
  config,
  ...
}:
let
  vars = config.vars;
in
{
  flake.modules.nixos.building = {
    programs.nh = {
      enable = true;
      flake = vars.configLocation;
      clean.enable = true;
    };
  };

  flake.modules.homeManager.building = {
    programs.nix-init.enable = true;
  };
}
