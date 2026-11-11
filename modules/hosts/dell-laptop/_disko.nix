{
  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=25%"
        "mode=755"
      ];
    };

    disk.main = {
      # Calamares rewrites this to the disk selected during install.
      # For later rebuilds, replace it with the stable /dev/disk/by-id/... path.
      device = "/dev/nvme0n1";
      type = "disk";

      content = {
        type = "gpt";

        partitions = {
          ESP = {
            name = "ESP";
            size = "1G";
            type = "EF00";

            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          luks = {
            name = "luks";
            size = "100%";
            type = "8309";

            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;

              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes = {
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  };

                  "@persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
