{
  config,
  ...
}:
let
  userName = baseNameOf (toString ./.);
  suffix = builtins.replaceStrings [ ".nix" ] [ "" ] (
    baseNameOf (builtins.unsafeGetAttrPos "suffix" { suffix = null; }).file
  );
  flakeModules = config.flake.modules;
in
{
  flake.modules.nixos."users-${userName}-${suffix}" = {
    home-manager.sharedModules = [
      flakeModules.homeManager."users-${userName}-${suffix}"
    ];
  };

  flake.modules.homeManager."users-${userName}-${suffix}" = {
    imports = with flakeModules.homeManager; [
      keepassxc
      kitty
      love
      obsidian
      opencode
      prusa-slicer
      spicetify
      vesktop
      vscodium
      zen-browser
    ];

    modules.homeManager.zen-browser = {
      allowedCookieSites = [
        "https://google.com"
        "https://duckduckgo.com"
        "https://github.com"
        "https://spotify.com"
        "https://twitch.tv"
        "https://youtube.com"
        "https://oraclecloud.com"
      ];
      uBlockBlocklist = [
        "www.youtube.com##ytd-rich-section-renderer.ytd-rich-grid-renderer.style-scope"
        "dashboard.twitch.tv##.cmdNOM.Layout-sc-1xcs6mc-0"
      ];
    };
  };
}
