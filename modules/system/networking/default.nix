{
  flake.modules.nixos.network = { ... }: {
    networking = {
      networkmanager.enable = true;
      firewall.enable = true;
    };

    environment.persistence."/persistent".directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/NetworkManager"
    ];
  };
}
