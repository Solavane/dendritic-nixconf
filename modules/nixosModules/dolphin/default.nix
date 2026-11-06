{
  flake.modules.homeManager.dolphin = { config, pkgs, ... }: {
    modules.homeManager.mango.apps = [ "dolphin" ];

    home.persistence."/persistent".directories = [
      ".local/share/dolphin"
    ];

    home.persistence."/persistent".files = [
      ".local/state/dolphinstaterc"
    ];

    home.packages = [
      pkgs.kdePackages.dolphin

      # Thumbnails and previews
      pkgs.kdePackages.kio-extras
      pkgs.kdePackages.ffmpegthumbs
      pkgs.kdePackages.kdegraphics-thumbnailers
    ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications."inode/directory" = "org.kde.dolphin.desktop";
    };
  };
}
