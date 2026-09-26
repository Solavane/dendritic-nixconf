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
      dolphin
      ly
      mango
      obsidian
    ];

    environment.systemPackages = with pkgs; [
      wlr-randr
      wl-mirror
      wdisplays
    ];
  };
}
