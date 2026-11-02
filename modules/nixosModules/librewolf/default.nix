{
  flake.modules.homeManager.librewolf = {
    modules.homeManager.mango.apps = [ "librewolf" ];

    home.persistence."/persistent".directories = [
      ".config/librewolf"
      ".mozilla"
    ];

    programs.librewolf = {
      enable = true;
    };
  };
}
