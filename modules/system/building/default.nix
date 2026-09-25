{
  flake.modules.nixos.building = {
    
    # Nix Helper. "nh os switch" to rebuild
    programs.nh = {
      enable = true;
      flake = "/home/$user/nixconfig"; 
      clean.enable = true;
    };
  };

  flake.modules.homeManager.building = {
    programs.nix-init.enable = true;
  };
}
