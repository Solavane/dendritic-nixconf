{
  lib,
  ...
}:
{
  flake.modules.nixos.nvidia = { config, ... }: {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable      = true;
      powerManagement.enable  = lib.mkDefault true; # enable if you see sleep/wake issues
      open                    = lib.mkDefault true;
      nvidiaSettings          = false;
      package                 = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
    };

    hardware.graphics.enable = true;

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME         = "nvidia";
      XDG_SESSION_TYPE          = "wayland";
      GBM_BACKEND               = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS   = "1";
    };
    
    nix.settings = {
      substituters          = [ "https://cache.nixos-cuda.org" ];
      trusted-public-keys   = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
    };
  };
}
