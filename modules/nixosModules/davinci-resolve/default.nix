{
  flake.modules.homeManager.davinci-resolve = { pkgs, ... }: {
    home.packages = with pkgs; [
      davinci-resolve
    ];
  };
}