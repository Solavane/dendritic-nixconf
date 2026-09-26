{
  inputs,
  ...
}:
{
  flake.modules.nixos.blender-cuda = { ... }: {
    nixpkgs.overlays = [
      (final: prev: {
        blender-cuda = inputs.omniflake.flakes.blender-cuda-nixos.packages.${final.stdenv.hostPlatform.system};
      })
    ];
  };

  flake.modules.homeManager.blender = { osConfig, pkgs, ... }: {
    home.packages =
      if (osConfig.modules.nixos.nvidia.enable or false) then
      [ pkgs.blender-cuda.blender-with-cuda-unstable ]
      else
      [ pkgs.blender ];
  };
}
