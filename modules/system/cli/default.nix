{
  config,
  ...
}:
let
  flakeModules = config.flake.modules;
in
{
  flake.modules.nixos.cli = { pkgs, ... }: { 
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
    imports = with flakeModules.homeManager; [
      neovim
      zellij
    ];
  };
}
