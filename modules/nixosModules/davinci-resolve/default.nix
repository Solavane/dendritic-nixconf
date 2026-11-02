{
  flake.modules.homeManager.davinci-resolve = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "davinci-resolve" ];

    home.persistence."/persistent".directories = [
      ".local/share/DaVinciResolve"
    ];

    home.packages = with pkgs; [
      davinci-resolve
    ];
  };
}