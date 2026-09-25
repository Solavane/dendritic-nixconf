{
  flake.modules.nixos.dolphin = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.kdePackages.dolphin
    ];
  };
}
