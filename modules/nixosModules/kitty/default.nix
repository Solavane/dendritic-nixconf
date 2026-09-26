{
  flake.modules.homeManager.kitty = { config, ... }: {
    programs.kitty = {
      enable = true;
      extraConfig = ''
        include ${config.xdg.configHome}/kitty/themes/noctalia.conf
      '';
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
      };
    };
  };
}
