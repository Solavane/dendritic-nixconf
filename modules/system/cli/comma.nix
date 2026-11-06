{
  flake.modules.nixos.comma = { inputs, pkgs, ... }: {
    imports = [
      inputs.omniflake.flakes.nix-index-database.nixosModules.default
    ];

    programs.comma = {
      enable = true;
      package =
        inputs.omniflake.flakes.nix-index-database.packages.${pkgs.stdenv.hostPlatform.system}.comma-with-db;
      enableZshIntegration = false;
    };
  };
}
