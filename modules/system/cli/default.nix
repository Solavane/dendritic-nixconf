{
  flake.modules.nixos.cli = { config, pkgs, ... }: { 
    imports = with config.flake.modules.nixos; [
      nvim
      zellij
    ];

    # Shell
    programs.zsh.enable = true;
    
    # Launch non-installed commands through ", firefox"
    programs.comma = {
      enable = true;
      enableZshIntegration = true;
    };

    environment.systemPackages = with pkgs; [
      nitch
      nurl
      ripgrep
      statix
      unzip
      zip
    ];
  };
  flake.modules.homeManager.cli = {

  };
}
