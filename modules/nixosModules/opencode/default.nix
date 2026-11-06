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

      settings = {
        autoupdate = false;
        share = "disabled";

        model = "opencode/big-pickle";
      };

      cli = {
        theme = "system";
      };

      context = ''
        - This is a Dendritic Ephemeral NixOS system with flakes. Prefer `nix run`/`nix shell` over global installs.
        - Most flakes use omniflake to keep flake.nix light. Only use the normal flake if omniflake causes trouble.
        - Try to keep token usage and task scope light. Ask the user for opinions before installing apps or major changes.
        - Match the existing code style and prefer modular declarative solutions over imperative changes.
      '';
    };
  };
}
