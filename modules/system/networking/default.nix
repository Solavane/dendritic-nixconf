{
  flake.modules.nixos.network = { ... }: {
    networking = {
      networkmanager.enable = true;
      firewall.enable = true;
    };
  };
}
