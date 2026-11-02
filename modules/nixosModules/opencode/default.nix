{
  flake.modules.homeManager.opencode = {
    modules.homeManager.mango.apps = [ "opencode" ];

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
