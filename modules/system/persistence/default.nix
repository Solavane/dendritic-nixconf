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
  };
}
