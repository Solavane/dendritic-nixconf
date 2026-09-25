{
  ...
}:
{
  flake.modules.nixos.optimizations-storage = { 
    services = {
      fstrim.enable = true;

      udev.extraRules = ''
        # Set Kyber for NVMe
        ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="kyber"
        
        # Set BFQ for SATA SSDs/HDDs
        ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
      '';
    };
  };
}
