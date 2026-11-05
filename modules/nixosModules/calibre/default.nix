{
  lib,
  ...
}:
let
  ebookTypes = [
    "application/epub+zip"
    "application/ereader"
    "application/vnd.amazon.ebook"
    "application/x-fictionbook"
    "application/x-fictionbook+xml"
    "application/x-mobi8-ebook"
    "application/x-mobipocket-ebook"
    "application/x-mobipocket-subscription"
    "application/x-sony-bbeb"
    "text/fb2+xml"
  ];
in
{
  flake.modules.homeManager.calibre = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "calibre" ];

    home.persistence."/persistent".directories = [
      "Calibre Library"
      ".config/calibre"
      ".local/share/calibre"
    ];

    home.packages = [ pkgs.calibre ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = lib.genAttrs ebookTypes (_: "calibre-ebook-viewer.desktop");
    };
  };
}
