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

    fileSystems."/" = {
      options = [ "subvol=@" "compress=zstd:1" "noatime" "discard=async" ];
    };  
    fileSystems."/home" = {
      options = [ "subvol=@home" "compress=zstd:1" "noatime" ];
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

    modules = with config.flake.modules.nixos; [
      # System
      ./_hardware-configuration.nix
      desktop
      hostConfig
      localsend
      nvidia
      optimizations
      steam
      
      #users
      users-solavane
      users-solavane-desktop
    ];
  };
}
