{
  flake.modules.nixos.building = { config, ... }: {
    
    # Nix Helper. "nh os switch" to rebuild
    programs.nh = {
      enable = true;
      flake = "${config.users.users.solavane.home}/nixconfig"; 
      clean.enable = true;
    };
  };

  flake.modules.homeManager.building = {
    programs.nix-init.enable = true;
  };
}
