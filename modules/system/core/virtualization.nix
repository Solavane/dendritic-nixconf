{ pkgs, ... }: {
  flake.modules.nixos.virtualization = {
    virtualisation.vmVariant = {
      virtualisation.fileSystems."/persistent".neededForBoot = true;
      virtualisation.fileSystems."/nix".neededForBoot = true;
    };

    virtualisation.vmVariantWithDisko = {
      virtualisation.fileSystems."/persistent".neededForBoot = true;
      virtualisation.fileSystems."/nix".neededForBoot = true;
      disko.devices.disk.main.content.partitions.luks.content.passwordFile =
        toString (pkgs.writeText "vm-luks-pass" "testpass");
    };
  };
}
