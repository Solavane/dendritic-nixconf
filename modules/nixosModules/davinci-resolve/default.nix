{
  flake.modules.homeManager.davinci-resolve = { pkgs, ... }: {
    home.persistence."/persistent".directories = [
      ".local/share/DaVinciResolve"
    ];

    home.packages = with pkgs; [
      davinci-resolve
    ];
  };
}