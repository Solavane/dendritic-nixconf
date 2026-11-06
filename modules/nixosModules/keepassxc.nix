{
  flake.modules.homeManager.keepassxc = { lib, pkgs, ... }:
  let
    # KeePassXC is a Qt5 application, while the session-wide platform theme
    # is qt6ct. Give it its own qt5ct environment without affecting Qt6 apps.
    keepassxc-themed = pkgs.symlinkJoin {
      name = "keepassxc-qt5ct";
      paths = [ pkgs.keepassxc ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/keepassxc" \
          --set QT_QPA_PLATFORMTHEME qt5ct
      '';
    };
  in
  {
    modules.homeManager.mango.apps = [ "keepassxc" ];

    home.persistence."/persistent".directories = [
      ".config/keepassxc"
      ".cache/keepassxc" ];

    programs.keepassxc = {
      enable = true;
      autostart = false;
      package = keepassxc-themed;
    };

    home.packages = [ pkgs.crudini ];

    home.activation = {
      configureKeepassxc = lib.hm.dag.entryAfter ["writeBoundary"] ''
        CONFIG_DIR="$HOME/.config/keepassxc"
        CONFIG_FILE="$CONFIG_DIR/keepassxc.ini"

        mkdir -p "$CONFIG_DIR"
        if [ ! -f "$CONFIG_FILE" ]; then
          echo "[General]" > "$CONFIG_FILE"
          echo "ConfigVersion=2" >> "$CONFIG_FILE"
        fi

        # This will ADD or UPDATE these keys but leave everything else (KeeShare) alone.
        ${pkgs.crudini}/bin/crudini --set "$CONFIG_FILE" "General" "MinimizeAfterUnlock" "false"
        ${pkgs.crudini}/bin/crudini --set "$CONFIG_FILE" "GUI" "AdvancedSettings" "true"
        ${pkgs.crudini}/bin/crudini --set "$CONFIG_FILE" "GUI" "ApplicationTheme" "dark"
        ${pkgs.crudini}/bin/crudini --set "$CONFIG_FILE" "GUI" "ColorPasswords" "true"
        ${pkgs.crudini}/bin/crudini --set "$CONFIG_FILE" "GUI" "CompactMode" "true"
        ${pkgs.crudini}/bin/crudini --set "$CONFIG_FILE" "GUI" "HidePasswords" "true"
        ${pkgs.crudini}/bin/crudini --set "$CONFIG_FILE" "GUI" "MinimizeOnStartup" "false"
        ${pkgs.crudini}/bin/crudini --set "$CONFIG_FILE" "GUI" "MinimizeOnClose" "true"
        ${pkgs.crudini}/bin/crudini --set "$CONFIG_FILE" "GUI" "MinimizeToTray" "true"
        ${pkgs.crudini}/bin/crudini --set "$CONFIG_FILE" "GUI" "ShowTrayIcon" "true"
        ${pkgs.crudini}/bin/crudini --set "$CONFIG_FILE" "Browser" "Enabled" "true"
        ${pkgs.crudini}/bin/crudini --set "$CONFIG_FILE" "Security" "IconDownloadFallback" "true"
        ${pkgs.crudini}/bin/crudini --set "$CONFIG_FILE" "FdoSecrets" "Enabled" "true"
      '';
    };
  };
}
