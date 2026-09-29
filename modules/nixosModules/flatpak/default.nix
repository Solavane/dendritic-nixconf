{
  flake.modules.nixos.flatpak = { inputs, ... }: {
    services.flatpak.enable = true;

    home-manager.sharedModules = [
      inputs.omniflake.flakes.nix-flatpak.homeManagerModules.nix-flatpak
    ];
  };

  flake.modules.homeManager.flatpak = { lib, ... }: {
    services.flatpak = {
      
      remotes = lib.mkOptionDefault [{
        name = "flathub-beta"; 
        location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
      }];

      packages = [
        "org.vinegarhq.Sober"
      ];

      update.onActivation = true;
    };
  };
}
