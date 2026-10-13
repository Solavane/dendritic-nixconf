{
  config,
  inputs,
  self,
  ...
}:
let
  hostName = baseNameOf (toString ./.);

  hostConfig = { pkgs, lib, ... }: {
    networking.hostName = hostName;
    system.stateVersion = "25.11";

    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      initrd = {
        systemd.enable = true;
        availableKernelModules = [
          "nvme"
          "r8169"
          "i2c_i801"
          "mei_me"
          "intel_lpss_pci"
          "intel_pch_thermal"
          "xhci_pci"
          "processor_thermal_device_pci_legacy"
          "i915"
          "usb_storage"
          "sd_mod"
        ];
      };

      kernelModules = [ "kvm-intel" ];
      kernelPackages = pkgs.linuxPackages;
    };

    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };

      bluetooth.enable = false;

      cpu.intel.updateMicrocode = lib.mkDefault true;
    };

    services = {
      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "prohibit-password";
        };
      };

      logind.settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
      };

      xserver.enable = false;
      thermald.enable = true;
      journald.settings.Journal.SystemMaxUse = "250M"; # cap the log length
    };

    # Enable passwordless sudo.
    security.sudo.extraRules = [
      {
        users = [ "solavane" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };

    # Disable documentation for minimal install.
    documentation.enable = false;

    networking = {
      useDHCP = lib.mkDefault true;
      firewall.allowedTCPPorts = [ 22 ];
    };

    # Battery storage cap.
    systemd.services.battery-charge-threshold = {
      wantedBy = [ "multi-user.target" ];
      script = ''
        echo 60 > /sys/class/power_supply/BAT0/charge_control_start_threshold
        echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold
      '';
      serviceConfig.Type = "oneshot";
    };

    users.users = {
      solavane.openssh.authorizedKeys.keyFiles = [ ./dell_laptop.pub ];
      root.openssh.authorizedKeys.keyFiles = [ ./dell_laptop.pub ];
    };
  };

  diskoConfig = {
    disko.devices.disk.main = {
      device = "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "4G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
in
{
  flake.nixosConfigurations."${hostName}" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };

    modules = [
      inputs.omniflake.flakes.disko.nixosModules.disko
      diskoConfig
    ] ++ (with config.flake.modules.nixos; [
      # System
      cli
      core
      hostConfig
      network
      optimizations

      #users
      users-solavane
      users-solavane-dell-laptop
    ]);
  };
}
