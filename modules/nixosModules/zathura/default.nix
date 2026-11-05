{
  lib,
  ...
}:
let
  pdfTypes = [
    "application/oxps"
    "application/pdf"
  ];

  djvuTypes = [
    "image/vnd.djvu"
    "image/vnd.djvu+multipage"
  ];

  postscriptTypes = [
    "application/eps"
    "application/postscript"
    "application/x-eps"
    "image/eps"
    "image/x-eps"
  ];

  comicTypes = [
    "application/vnd.comicbook+zip"
    "application/vnd.comicbook-rar"
    "application/x-cb7"
    "application/x-cbr"
    "application/x-cbt"
    "application/x-cbz"
  ];
in
{
  flake.modules.homeManager.zathura = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "zathura" ];

    home.persistence."/persistent".directories = [
      ".config/zathura"
      ".local/share/zathura"
    ];

    home.packages = [ pkgs.zathura ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications =
        lib.genAttrs pdfTypes (_: "org.pwmt.zathura-pdf-mupdf.desktop")
        // lib.genAttrs djvuTypes (_: "org.pwmt.zathura-djvu.desktop")
        // lib.genAttrs postscriptTypes (_: "org.pwmt.zathura-ps.desktop")
        // lib.genAttrs comicTypes (_: "org.pwmt.zathura-cb.desktop");
    };
  };
}
