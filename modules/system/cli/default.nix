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

  flake.modules.homeManager.cli = { config, osConfig, pkgs, ... }: {
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
        historySubstringSearch.enable = true;
        dotDir = "${config.xdg.configHome}/zsh";
        shellAliases = import ./_aliases.nix;
        history.size = 100000;

        setOptions = [
        ];

        initContent = ''
        nitch
        source ${config.xdg.configHome}/zsh/add-eq.sh

        if [[ -r "${config.xdg.configHome}/fzf/themes/noctalia.sh" ]]; then
          source "${config.xdg.configHome}/fzf/themes/noctalia.sh"
        fi
        '';

        oh-my-zsh = {
          enable = true;
          theme = "refined";
        };
      };

      btop = {
        enable = true;
        package =
          if (osConfig.modules.nixos.nvidia.enable or false) then
            pkgs.btop-cuda
          else
            pkgs.btop;
        # Noctalia generates ~/.config/btop/themes/noctalia.theme and its
        # apply hook only selects it when btop.conf is writable. Keep the
        # selection declarative so the read-only Home Manager config works.
        settings.color_theme = "noctalia";
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
