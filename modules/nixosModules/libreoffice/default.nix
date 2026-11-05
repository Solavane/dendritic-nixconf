{
  ...
}:
{
  flake.modules.homeManager.libreoffice = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "libreoffice" ];

    home.persistence."/persistent".directories = [
      ".config/libreoffice"
    ];

    home.packages = [ pkgs.libreoffice ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/msword" = "writer.desktop";
        "application/rtf" = "writer.desktop";
        "application/vnd.ms-word.document.macroenabled.12" = "writer.desktop";
        "application/vnd.oasis.opendocument.text" = "writer.desktop";
        "application/vnd.oasis.opendocument.text-template" = "writer.desktop";
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "writer.desktop";
        "application/vnd.openxmlformats-officedocument.wordprocessingml.template" = "writer.desktop";
        "text/rtf" = "writer.desktop";

        "application/vnd.ms-excel" = "calc.desktop";
        "application/vnd.oasis.opendocument.spreadsheet" = "calc.desktop";
        "application/vnd.oasis.opendocument.spreadsheet-template" = "calc.desktop";
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "calc.desktop";
        "application/vnd.openxmlformats-officedocument.spreadsheetml.template" = "calc.desktop";
        "text/csv" = "calc.desktop";

        "application/vnd.ms-powerpoint" = "impress.desktop";
        "application/vnd.oasis.opendocument.presentation" = "impress.desktop";
        "application/vnd.oasis.opendocument.presentation-template" = "impress.desktop";
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "impress.desktop";
        "application/vnd.openxmlformats-officedocument.presentationml.template" = "impress.desktop";

        "application/vnd.oasis.opendocument.graphics" = "draw.desktop";
        "application/vnd.oasis.opendocument.graphics-template" = "draw.desktop";

        "application/vnd.oasis.opendocument.formula" = "math.desktop";
        "application/vnd.oasis.opendocument.formula-template" = "math.desktop";

        "application/vnd.oasis.opendocument.database" = "base.desktop";
      };
    };
  };
}
