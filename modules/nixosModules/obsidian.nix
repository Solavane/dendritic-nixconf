{
  inputs,
  ...
}:
{
  # The overlay has to live on the system pkgs: home-manager runs with
  # `useGlobalPkgs = true`, so the HM `pkgs` below only sees overlays that were
  # applied through the `nixpkgs` module.
  flake.modules.nixos.obsidian = { ... }: {
    nixpkgs.overlays = [
      inputs.obsidian-extensions.overlays.default
    ];
  };

  flake.modules.homeManager.obsidian = { pkgs, ... }: {
    programs.obsidian = {
      enable = true;

      vaults.notes.target = "Documents/Obsidian";

      defaultSettings = {
        app = {
          alwaysUpdateLinks = true;
          spellcheck = true;
        };

        corePlugins = [
          "backlink"
          "bases"
          "bookmarks"
          "canvas"
          "command-palette"
          "graph"
          "file-explorer"
          "page-preview"
          "slash-command"
          {
            name = "templates";
            settings.folder = "Functional/Templates";
          }
          {
            name = "daily-notes";
            settings = {
              folder = "Daily";
              format = "YYYY-MM-DD";
              template = "Functional/Templates/Daily note";
            };
          }
        ];
        communityPlugins = with pkgs.obsidianPlugins; [
          calendar
          obsidian-day-planner
          docxer
        ];
      };
    };
  };
}
