{
  flake.modules.nixos.optimizations-lact = {
    services.lact = {
      enable = true;
    };
  };
}
