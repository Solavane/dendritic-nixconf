{
  flake.modules.homeManager.librewolf = {
    home.persistence."/persistent".directories = [
      ".config/librewolf"
      ".mozilla"
    ];

    programs.librewolf = {
      enable = true;
    };
  };
}
