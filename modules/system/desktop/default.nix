{
  config,
  ...
}:
{

  flake.modules.nixos.desktop = {
    imports = with config.flake.modules.nixos; [
      building
      cli
      core
      dolphin
      ly
      mango
    ];
  };
}
