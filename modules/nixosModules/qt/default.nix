{
  flake.modules.nixos.qt = {
    # Home Manager session variables are only sourced by login shells. Mango is
    # started by ly, so use the NixOS Qt module, which publishes these values
    # through PAM and adds the user profile's Qt plugin directories.
    qt = {
      enable = true;
      platformTheme = "kde";
    };

    # The NixOS Qt module publishes Qt paths through PAM but keeps the platform
    # theme name in environment.variables, which only login shells read. Set it
    # as a session variable as well so ly-launched Mango sessions inherit it.
    environment.sessionVariables.QT_QPA_PLATFORMTHEME = "kde";
  };

  flake.modules.homeManager.qt = { config, pkgs, ... }: {
    # Dolphin and the other KDE applications use KColorScheme from kdeglobals,
    # which Noctalia maintains through its KColorScheme template. The KDE
    # platform theme hands the same scheme to the remaining Qt applications.
    qt = {
      enable = true;
      platformTheme.name = "kde";

      # KeePassXC is still Qt5. Its wrapper selects qt5ct so it does not try to
      # load the Qt6-only KDE platform theme plugin.
      qt5ctSettings = {
        Appearance = {
          color_scheme_path = "${config.xdg.configHome}/qt5ct/colors/noctalia.conf";
          custom_palette = false;
          style = "Fusion";
        };
      };
    };

    home.packages = [ pkgs.libsForQt5.qt5ct ];
  };
}
