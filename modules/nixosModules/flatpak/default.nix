{
  flake.modules.nixos.flatpak = { inputs, ... }: {
    services.flatpak.enable = true;

    home-manager.sharedModules = [
      inputs.omniflake.flakes.nix-flatpak.homeManagerModules.nix-flatpak
    ];
  };

  flake.modules.homeManager.flatpak = { lib, ... }: {
    home.persistence."/persistent".directories = [
      ".local/share/flatpak"
      ".var/app"
    ];

    services.flatpak = {
      
      remotes = lib.mkOptionDefault [{
        name = "flathub-beta"; 
        location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
      }];

      packages = [
        "org.vinegarhq.Sober"
        "org.vinegarhq.Vinegar"
      ];

      update.onActivation = true;
    };
  };
}
