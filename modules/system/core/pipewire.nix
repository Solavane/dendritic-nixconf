{
  flake.modules.nixos.pipewire = { config, lib, pkgs, ... }: {
    services.pipewire = {
      enable = true;
      jack.enable = true;
      alsa.enable = true;
      pulse.enable = true;

      # Without the stock pipewire.conf in /etc/pipewire, PipeWire aborts
      # config loading before it ever reads conf.d, so every drop-in from
      # extraConfig is silently ignored. configPackages defaults to [].
      configPackages = [ pkgs.pipewire ];
    };
    security.rtkit.enable = true;

    environment.persistence."/persistent".users.solavane.directories = lib.mkIf (
      config.environment.persistence."/persistent".enable or false
    ) [
      ".local/state/wireplumber"
    ];
  };
}
