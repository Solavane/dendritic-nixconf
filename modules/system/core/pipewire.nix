{
  flake.modules.nixos.pipewire = { pkgs, ... }: {
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
  };
}
