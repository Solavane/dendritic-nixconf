{
  flake.modules.homeManager.opencode = {
    home.persistence."/persistent".directories = [
      ".config/opencode"
      ".local/share/opencode"
      ".local/state/opencode"
    ];

    programs.opencode = {
      enable = true;
    };
  };
}
