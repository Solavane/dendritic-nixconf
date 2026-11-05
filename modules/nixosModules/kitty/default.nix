{
  flake.modules.homeManager.kitty = { config, ... }: {
    modules.homeManager.mango.apps = [ "kitty" ];

    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        include = "${config.xdg.configHome}/kitty/themes/noctalia.conf";
      };
    };
  };
}
