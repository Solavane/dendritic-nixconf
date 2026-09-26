{
  flake.modules.homeManager.spicetify = { inputs, pkgs, ... }: 
  let
    spicePkgs = inputs.omniflake.flakes.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
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
      ];
    };
  };
}
