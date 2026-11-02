{
  flake.modules.homeManager.foot = {
    modules.homeManager.mango.apps = [ "foot" ];

    programs.foot = {
      enable = true;
    };
  };
}
