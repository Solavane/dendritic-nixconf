{
  flake.modules.nixos.comfyui = { config, inputs, lib, pkgs, ... }: {
    environment.systemPackages = [
      inputs.omniflake.pinned.nixified-ai.packages.${pkgs.system}.comfyui-nvidia
    ];

    nix.settings.trusted-substituters = [ "https://ai.cachix.org" ];
    nix.settings.trusted-public-keys = [
      "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
    ];

    environment.persistence."/persistent".users.solavane.directories = lib.mkIf (
      config.environment.persistence."/persistent".enable or false
    ) [
      ".config/comfyui"
      ".local/share/comfyui"
    ];
  };
}
