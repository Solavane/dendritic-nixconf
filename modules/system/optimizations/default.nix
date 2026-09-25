{
  config,
  ...
}:
{
  flake.modules.nixos.optimizations = {
    imports = with config.flake.modules.nixos; [
      optimizations-storage
    ];
  };
}
