{
  inputs,
  lib,
  ...
}:
let
  impermanenceModule = inputs.impermanence.nixosModules.impermanence;
in
{
  flake.modules.nixos.persistence = {
    imports = [ impermanenceModule ];

    environment.persistence."/persistent".enable = lib.mkDefault false;
  };

  flake.modules.nixos.impermanence = {
    environment.persistence."/persistent" = {
      enable = true;
      hideMounts = true;
      allowTrash = true;
    };

    boot.initrd.availableKernelModules = [ "dm_crypt" "btrfs" "nvme" ];

    fileSystems."/nix".neededForBoot = true;
    fileSystems."/persistent".neededForBoot = true;

    virtualisation.vmVariant = {
      virtualisation.fileSystems."/persistent".neededForBoot = true;
      virtualisation.fileSystems."/nix".neededForBoot = true;
    };

    virtualisation.vmVariantWithDisko = {
      virtualisation.fileSystems."/persistent".neededForBoot = true;
      virtualisation.fileSystems."/nix".neededForBoot = true;
    };
  };
}
