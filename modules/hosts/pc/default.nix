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

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    boot.kernelPackages = pkgs.linuxPackages_zen;

    services = {
      undervolt = {
        enable = true;
        coreOffset = -80;
      };
    };
  };
in
{
  flake.nixosConfigurations."${hostName}" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };

    modules = [
      inputs.omniflake.flakes.disko.nixosModules.disko
      ./_disko.nix
    ] ++ (with config.flake.modules.nixos; [
      # System
      ./_hardware-configuration.nix
      audio-latency
      #comfyui
      comma
      desktop
      equalizer-lcd-2c
      flatpak
      hostConfig
      impermanence
      localsend
      tpm2
      nvidia
      optimizations
      optimizations-lact
      steam
      virtualization

      # Users
      users-solavane
      users-solavane-desktop
      users-solavane-pc
    ]);
  };
}
