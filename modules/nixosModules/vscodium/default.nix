{
  flake.modules.homeManager.vscodium = {
    home.persistence."/persistent".directories = [
      ".config/VSCodium"
      ".local/state/VSCodium"
      ".vscode-oss"
      ".vscode-oss-shared"
    ];

    programs.vscodium = {
      enable = true;
    };
  };
}
