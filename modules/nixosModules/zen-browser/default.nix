{
  config,
  lib,
  ...
}:
let
  extension = shortId: guid: {
    name = guid;
    value = {
      install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
      installation_mode = "normal_installed";
    };
  };

  extensions = [
    # To add additional extensions, find it on addons.mozilla.org, find
    # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
    # Then go to https://addons.mozilla.org/api/v5/addons/addon/!SHORT_ID!/ to get the guid
    # Adding many extensions makes it easier for websites to fingerprint you
    (extension "ublock-origin" "uBlock0@raymondhill.net")
    (extension "sponsorblock"  "sponsorBlocker@ajay.app")
    (extension "violentmonkey" "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}")
  ];

  ## Enables keepassxc-browser extension if keepass option is enabled
  #++ lib.optional config.nixconf.programs.keepass.enable
  #  (extension "keepassxc-browser" "keepassxc-browser@keepassxc.org");
in
{
  flake.modules.homeManager.zen-browser = { inputs, pkgs, ... }: {
    home.packages = [
      (pkgs.wrapFirefox
        inputs.omniflake.flakes.zen-browser-flake-youwen5.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped
        {
          extraPrefs = lib.concatLines (
            lib.mapAttrsToList (
              name: value: ''lockPref(${lib.strings.toJSON name}, ${lib.strings.toJSON value});''
            ) (import ./_prefs.nix)
          );

          extraPolicies = {
            DisableTelemetry = true;
            ExtensionSettings = builtins.listToAttrs extensions;

            Cookies = {
              #Allow = cfg.allowedCookieSites;
              Default = true;
            };

            "3rdparty".Extensions = {
              "uBlock0@raymondhill.net" = {
                #adminSettings = {
                #  userFilters = lib.concatStringsSep "\n" cfg.uBlockBlocklist;
                #};
              };
            };

            SearchEngines = {
              Default = "ddg";
              Add = [
                {
                  Name = "nixpkgs packages";
                  URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
                  IconURL = "https://wiki.nixos.org/favicon.ico";
                  Alias = "@np";
                }
                {
                  Name = "NixOS options";
                  URLTemplate = "https://search.nixos.org/options?query={searchTerms}";
                  IconURL = "https://wiki.nixos.org/favicon.ico";
                  Alias = "@no";
                }
                {
                  Name = "NixOS Wiki";
                  URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
                  IconURL = "https://wiki.nixos.org/favicon.ico";
                  Alias = "@nw";
                }
                {
                  Name = "noogle";
                  URLTemplate = "https://noogle.dev/q?term={searchTerms}";
                  IconURL = "https://noogle.dev/favicon.ico";
                  Alias = "@ng";
                }
                {
                  Name = "MyNixOS";
                  URLTemplate = "https://mynixos.com/search?q={searchTerms}";
                  IconURL = "https://mynixos.com/favicon.ico";
                  Alias = "@mn";
                }
              ];
            };
          };
        }
      )
    ];
  };
}
