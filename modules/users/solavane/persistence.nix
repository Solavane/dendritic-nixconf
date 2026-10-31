{
  config,
  ...
}:
let
  userName = baseNameOf (toString ./.);
in
{
  flake.modules.nixos."users-${userName}-persist" = {
    home-manager.users.${userName}.imports = [
      config.flake.modules.homeManager."users-${userName}-persist"
    ];
  };

  flake.modules.homeManager."users-${userName}-persist" = {
    home.persistence."/persistent" = {
      enable = true;

      directories = [
        "Desktop"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Projects"
        "Videos"

        "git"
        "nixconfig"

        ".config/autostart"
        ".config/kde"
        ".gradle"
        ".java"
        ".local/share/color-schemes"
        ".local/share/fonts"
        ".local/share/icons"
        ".local/share/themes"
        ".local/share/zsh"
        ".local/share/zoxide"
        ".npm"
        ".nv"
        ".ollama"
        ".pki"
        ".wine"
        
        { directory = ".secrets"; mode = "0700"; }
        { directory = ".local/share/keyrings"; mode = "0700"; }
        { directory = ".ssh"; mode = "0700"; }
        { directory = ".gnupg"; mode = "0700"; }
      ];

      files = [
        ".bash_history"
        ".gitconfig"
        ".nvidia-settings-rc"
      ];
    };
  };
}
