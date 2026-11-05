{
  lib,
  ...
}:
let
  imageTypes = [
    "image/avif"
    "image/bmp"
    "image/gif"
    "image/heif"
    "image/jpeg"
    "image/jxl"
    "image/png"
    "image/qoi"
    "image/svg+xml"
    "image/tiff"
    "image/webp"
    "image/x-bmp"
    "image/x-farbfeld"
  ];
in
{
  flake.modules.homeManager.imv = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "imv" ];

    home.packages = [ pkgs.imv ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = lib.genAttrs imageTypes (_: "imv.desktop");
    };
  };
}
