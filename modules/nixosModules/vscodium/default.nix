{
  flake.modules.homeManager.vscodium = {
    modules.homeManager.mango.apps = [ "codium" ];

    home.persistence."/persistent".directories = [
      ".config/VSCodium"
      ".local/state/VSCodium"
      ".vscode-oss"
      ".vscode-oss-shared"
    ];

    programs.vscodium = {
      enable = true;
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications."text/plain" = "codium.desktop";
    };
  };
}
