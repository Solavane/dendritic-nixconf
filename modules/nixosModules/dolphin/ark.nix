{
  lib,
  ...
}:
let
  archiveTypes = [
    "application/gzip"
    "application/vnd.debian.binary-package"
    "application/x-7z-compressed"
    "application/x-archive"
    "application/x-bzip"
    "application/x-bzip2"
    "application/x-compressed-tar"
    "application/x-cpio"
    "application/x-deb"
    "application/x-gzip"
    "application/x-lz4"
    "application/x-lz4-compressed-tar"
    "application/x-lzma"
    "application/x-rar"
    "application/x-rar-compressed"
    "application/x-rpm"
    "application/x-tar"
    "application/x-tarz"
    "application/x-xz"
    "application/x-xz-compressed-tar"
    "application/x-zip-compressed"
    "application/x-zstd"
    "application/x-zstd-compressed-tar"
    "application/zip"
    "application/zstd"
  ];
in
{
  flake.modules.homeManager.ark = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "ark" ];

    home.packages = with pkgs; [
      kdePackages.ark
      p7zip
      unrar
      zstd
    ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = lib.genAttrs archiveTypes (_: "org.kde.ark.desktop");
    };
  };
}
