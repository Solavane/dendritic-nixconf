{
  config,
  ...
}:
{
  flake.modules.nixos.desktop = { pkgs, ... }: {
    imports = with config.flake.modules.nixos; [
      building
      cli
      core
      locale
      ly
      mango
      obsidian
      pipewire
    ];

    environment.systemPackages = with pkgs; [
      wlr-randr
      wl-mirror
      wdisplays
    ];

    environment.persistence."/persistent".directories = [
      "/var/lib/AccountsService"
      "/var/lib/bluetooth"
      "/var/lib/systemd/rfkill"
      "/var/lib/upower"
    ];
  };
}
