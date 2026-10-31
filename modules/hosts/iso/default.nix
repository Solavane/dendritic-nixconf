{
  config,
  inputs,
  self,
  ...
}:
let
  hostName = baseNameOf (toString ./.);

  hostConfig = { pkgs, ... }: {
    networking.hostName = hostName;
    system.stateVersion = "25.11";

    boot.kernelPackages = pkgs.linuxPackages_zen;
  };
in
{
  flake.nixosConfigurations."${hostName}" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };

    modules = with config.flake.modules.nixos; [ (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix") ]
    ++ [
      # System
      desktop
      hostConfig
      installer
      localsend
      optimizations

      # Users
      users-solavane
      users-solavane-desktop
    ];
  };
}
