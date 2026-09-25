{
  ...
}:
{
  flake.modules.nixos.core = { pkgs, ... }: {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      deprecated-features   = [ "or-as-identifier" ];
      auto-optimise-store   = true;
    };

    nixpkgs.config.allowUnfree = true; 

    # Switch nix to lix
    nix.package = pkgs.lixPackageSets.stable.lix;
    nixpkgs.overlays = [ (final: prev: {
      inherit (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena;
    }) ];

    services = {
      # Sync time with Network Time Protocol
      ntp.enable = true;
      
      # GNOME Virtual File System
      gvfs.enable = true;
    };
    programs = {
      git.enable = true;

      # Gsettings config backend
      dconf.enable = true;
    };

    # Allows unprivileged processes to speak to privileged ones
    security.polkit.enable = true;
  };
}
