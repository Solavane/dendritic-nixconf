{ 
  lib, 
  ... 
}:
{
  config.systems = [
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  options.flake.modules.nixos = lib.mkOption {
    type = lib.types.attrsOf lib.types.deferredModule;
    default = { };
    description = "NixOS module definitions keyed by name";
  };

  options.flake.modules.homeManager = lib.mkOption {
    type = lib.types.attrsOf lib.types.deferredModule;
    default = { };
    description = "home-manager module definitions keyed by name";
  };
}

