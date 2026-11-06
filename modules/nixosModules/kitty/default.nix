{
  flake.modules.homeManager.kitty = { config, ... }: {
    modules.homeManager.mango.apps = [ "kitty" ];

    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        include = "${config.xdg.configHome}/kitty/themes/noctalia.conf";

        scrollback_lines = 10000;
        mouse_hide_wait = 3.0;
        
        #Appearance
        window_padding_width = 10;
        font_size = 14;

        dynamic_background_opacity = true;
        background_opacity = "0.7";

        #Cursor trail
        cursor_trail = 1;
        cursor_trail_decay = "0.01 0.2";
        cursor_trail_start_threshold = 2;
      };
    };
  };
}
