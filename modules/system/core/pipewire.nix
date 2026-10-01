{
  flake.modules.nixos.pipewire = {
    services.pipewire = {
      enable = true;
      jack.enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    security.rtkit.enable = true;
  };
}
