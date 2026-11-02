{
  flake.modules.nixos.tpm2 = {
    security.tpm2.enable = true;
    boot.initrd.luks.devices."cryptroot".crypttabExtraOpts = [ "tpm2-device=auto" ];
  };
}
