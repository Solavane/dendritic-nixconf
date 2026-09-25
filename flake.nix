{
  description = "Solavane's Dendritic NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    omniflake.url = "github:fzakaria/omniflake";
    omniflake.inputs.nixpkgs.follows = "nixpkgs";
    
    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: 
    inputs.omniflake.inputs.flake-parts.lib.mkFlake { inherit inputs; } 
      (inputs.omniflake.flakes.import-tree ./modules);
}
