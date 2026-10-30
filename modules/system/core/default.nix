{
  config,
  ...
}:
{
  flake.modules.nixos.core = { pkgs, ... }: {
    imports = [
      config.flake.modules.nixos.persistence
      config.flake.modules.nixos.temporary-password
    ];

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

    fonts.packages = [
      pkgs.nerd-fonts.jetbrains-mono
    ];

    # Allows unprivileged processes to speak to privileged ones
    security.polkit.enable = true;

    environment.persistence."/persistent" = {
      directories = [
        "/var/lib/nixos"
        "/var/lib/systemd/timers"
        "/var/lib/systemd/timesync"
        "/var/log"
        "/etc/ssh"
      ];

      files = [
        "/etc/machine-id"
        { file = "/var/lib/systemd/random-seed"; method = "symlink"; }
        { file = "/etc/ssh/ssh_host_ed25519_key"; method = "symlink"; }
        { file = "/etc/ssh/ssh_host_rsa_key"; method = "symlink"; }
      ];
    };

    virtualisation.vmVariantWithDisko = {
      disko.devices.disk.main.content.partitions.luks.content.passwordFile =
        toString (pkgs.writeText "vm-luks-pass" "testpass");
    };
  };
}
