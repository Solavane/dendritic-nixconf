{
  flake.modules.homeManager.faugus = { pkgs, ... }: {
    home.persistence."/persistent".directories = [
      ".config/faugus-launcher"
      ".local/share/faugus-launcher"
      ".local/state/faugus-launcher"
      "Faugus"
      "faugus-launcher"
    ];

    home.packages = with pkgs; [
      faugus-launcher
    ];
  };
}
