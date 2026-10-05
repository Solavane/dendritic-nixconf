{ 
  config,
  inputs, 
  self,
  ... 
}: 
let
  hostName = baseNameOf (toString ./.);

  hostConfig = { pkgs, ... }: {
    networking.hostName = hostName;
    system.stateVersion = "25.11";

    boot.loader = {
      systemd-boot.enable = false;
      grub = {
        enable = true;
        device = "/dev/sda";
      };
    };

    boot.kernelPackages = pkgs.linuxPackages_latest;

    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    environment.systemPackages = with pkgs; [
      acpi # Battery / power state inspector
    ];
  };
in
{
  flake.nixosConfigurations."${hostName}" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };

    modules = with config.flake.modules.nixos; [
      # System
      ./_hardware-configuration.nix
      desktop
      flatpak
      hostConfig
      localsend
      mango-old-laptop
      network
      optimizations
      steam

      #users
      users-solavane
      users-solavane-desktop
    ];
  };
}
