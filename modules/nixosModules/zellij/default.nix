{
  flake.modules.homeManager.zellij = {
    modules.homeManager.mango.apps = [ "zellij" ];

    programs.zellij = {
      enable = true;
    };
  };
}
