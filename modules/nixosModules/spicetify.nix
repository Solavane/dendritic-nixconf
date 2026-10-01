{
  flake.modules.homeManager.spicetify = { inputs, pkgs, ... }: 
  let
    spicePkgs = inputs.omniflake.flakes.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};

    spotifyGenres = {
      src = pkgs.fetchFromGitHub {
        owner = "Vexcited";
        repo = "better-spotify-genres";
        rev = "2b634d7a0cb159715076758efd48a29105b8ff21";
        hash = "sha256-3VZTiHhYO7RBZ/u1hZ/fcKO0u/Rg9/iTos8uZ0Ogpag=";
      };
      name = "spotifyGenres.js";
    };
  in
  {
    imports = [
      inputs.omniflake.flakes.spicetify-nix.homeManagerModules.default
    ];

    programs.spicetify = {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
      enabledExtensions = with spicePkgs.extensions; [
        hidePodcasts
        shuffle
        goToSong
        savePlaylists
        copyLyrics
        starRatings
        allOfArtist
        aiBandBlocker
        sortPlay
        sideHide
        bookmark
        keyboardShortcut
        skipOrPlayLikedSongs
        featureShuffle
        spotifyGenres
      ];
    };
  };
}
