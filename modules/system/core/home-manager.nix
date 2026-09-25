{ 
  inputs, 
  ... 
}:
{
  flake.modules.nixos.core = { ... }: {
    imports = [ inputs.omniflake.flakes.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bkup-home-manager-${toString inputs.self.lastModifiedDate }";
      extraSpecialArgs = { inherit inputs; };
    };
  };
}
