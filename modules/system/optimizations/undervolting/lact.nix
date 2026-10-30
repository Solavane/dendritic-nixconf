{
  flake.modules.nixos.optimizations-lact = {
    services.lact = {
      enable = true;
    };

    environment.persistence."/persistent".directories = [
      "/etc/lact"
    ];
  };
}
