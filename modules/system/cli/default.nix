{
  config,
  ...
}:
let
  flakeModules = config.flake.modules;
in
{
  flake.modules.nixos.cli = { pkgs, ... }: { 
    programs = {
      # Shell
      zsh.enable = true;

      # Launch non-installed commands through ", firefox"
      comma = {
        enable = true;
        enableZshIntegration = true;
      };
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

  flake.modules.homeManager.cli = { config, ... }: {
    imports = with flakeModules.homeManager; [
      neovim
      zellij
    ];

    programs = {
      zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        dotDir = "${config.xdg.configHome}/zsh";
        shellAliases = import ./_aliases.nix;

        setOptions = [
        ];

        initContent = ''
        nitch
        source ${config.xdg.configHome}/zsh/add-eq.sh
        '';
      };

      eza = {
        enable = true;
        enableZshIntegration = true;
      };

      fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    };

    # add-eq lives as a real file so it stays readable and editable
    xdg = {
      enable = true;
      configFile."zsh/add-eq.sh".source = ./_add-eq.sh;
    };
  };
}
