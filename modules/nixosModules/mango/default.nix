{
  config,
  inputs,
  ...
}:
{
  flake.modules.nixos.mango = { ... }: {
    imports = [
      inputs.mango.nixosModules.mango
    ];
    programs.mango.enable = true;
    programs.noctalia.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [ ];  
      wlr.enable = true;
    };

    home-manager.sharedModules = [
      config.flake.modules.homeManager.mango
    ];
  };
  
  flake.modules.homeManager.mango = { ... }: {
    imports = [
      inputs.mango.hmModules.mango
    ];
    wayland.windowManager.mango = {
      enable = true;
      autostart_sh = ''
        noctalia &
        systemctl --user start xdg-desktop-portal.service --ignore-dependencies
      '';
      settings = {
        repeat_rate=50;
        repeat_delay=250;
        xkb_rules_layout="se";

        mouse_accel_profile = 0;
        mouse_accel_speed = -1;
        cursor_hide_on_keypress = 0;

        trackpad_accel_profile = 2;
        trackpad_accel_speed = 0.7;

        syncobj_enable = 1;
        focus_on_activate = 0;
        focus_cross_tag = 1;
        drag_tile_to_tile = 1;
        drag_corner = 4;
        no_border_when_single = 0;
        no_radius_when_single = 0;

        monitorrule = [
          "name:DP-1,     width:2560, height:1440, refresh:240, x:0, y:0, vrr:0"
          "name:DP-2,     width:2560, height:1440, refresh:60, x:2560, y:0, vrr:0"
          "name:HDMI-A-1, width:2560, height:1440, refresh:120,  x:0,    y:0"
        ];  

        tagrule = [
          "id:0, layout_name:dwindle"
          "id:1, layout_name:dwindle"
          "id:2, layout_name:dwindle"
          "id:3, layout_name:dwindle"
          "id:4, layout_name:dwindle"
          "id:5, layout_name:dwindle"
          "id:6, layout_name:dwindle"
          "id:7, layout_name:dwindle"
          "id:8, layout_name:dwindle"
          "id:9, layout_name:dwindle"
        ];

        # Keybindings
        bind = [
          # Mango Core
          "SUPER,r,reload_config"
          "SUPER,m,quit"
          "SUPER,q,killclient,"
          "SUPER,Space,togglefloating,"
          "SUPER,f,togglemaximizescreen,0"
          "SUPER+ctrl,f,togglefullscreen,"
          "SUPER+shift,f,togglefakefullscreen,"
          "SUPER,s,toggle_scratchpad"
          "SUPER+alt,Up,incgaps,+2"
          "SUPER+alt,Down,incgaps,-2"

          # Noctalia
          "SUPER,d,spawn,noctalia msg panel-toggle launcher"
          "SUPER,c,spawn,noctalia msg panel-toggle control-center"
          "SUPER,comma,spawn,noctalia msg settings-toggle"
          "SUPER,v,spawn,noctalia msg panel-toggle clipboard"
          "SUPER+shift,v,spawn,noctalia msg panel-toggle wallpaper"
          "SUPER+shift,s,spawn,noctalia msg panel-toggle session"
          "SUPER+shift,l,spawn,noctalia msg theme-mode-toggle"
          "SUPER+shift,n,spawn,noctalia msg notification-dnd-toggle"
          "SUPER+alt,w,spawn,noctalia msg wallpaper-random"
          "SUPER+alt,c,spawn,noctalia msg caffeine-toggle"

          # Workspace Navigation
          "SUPER,1,view,1"
          "SUPER,2,view,2"
          "SUPER,3,view,3"
          "SUPER,4,view,4"
          "SUPER,5,view,5"
          "SUPER,6,view,6"
          "SUPER,7,view,7"
          "SUPER,8,view,8"
          "SUPER,9,view,9"

          # Move to Workspace
          "CTRL+SUPER,1,tag,1"
          "CTRL+SUPER,2,tag,2"
          "CTRL+SUPER,3,tag,3"
          "CTRL+SUPER,4,tag,4"
          "CTRL+SUPER,5,tag,5"
          "CTRL+SUPER,6,tag,6"
          "CTRL+SUPER,7,tag,7"
          "CTRL+SUPER,8,tag,8"
          "CTRL+SUPER,9,tag,9"

          # Overview
          "SUPER,Tab,toggleoverview"

          # Window Focus
          "SUPER,Left,focusdir,left"
          "SUPER,Right,focusdir,right"
          "SUPER,Up,focusdir,up"
          "SUPER,Down,focusdir,down"
          # Vim bindings
          "SUPER,h,focusdir,left"
          "SUPER,l,focusdir,right"
          "SUPER,k,focusdir,up"
          "SUPER,j,focusdir,down"

          # Resize Window
          "SUPER+CTRL,Up,resizewin,+0,-50"
          "SUPER+CTRL,Down,resizewin,+0,+50"
          "SUPER+CTRL,Left,resizewin,-50,+0"
          "SUPER+CTRL,Right,resizewin,+50,+0"

          # Switch Layout
          "CTRL+SUPER,i,setlayout,dwindle"
          "CTRL+SUPER,l,setlayout,scroller"
          "SUPER,n,switch_layout"

          # Screenshots
          "NONE,Print,spawn,noctalia msg screenshot-region"
          "SHIFT,Print,spawn,noctalia msg screenshot-fullscreen"
          "CTRL,Print,spawn,noctalia msg screenshot-annotate"

          # Volume Controls
          "NONE,XF86AudioRaiseVolume,spawn,noctalia msg volume-up"
          "NONE,XF86AudioLowerVolume,spawn,noctalia msg volume-down"
          "NONE,XF86AudioMute,spawn,noctalia msg volume-mute"
          "SHIFT,XF86AudioMute,spawn,noctalia msg mic-mute"

          # Brightness
          "NONE,XF86MonBrightnessUp,spawn,noctalia msg brightness-up"
          "NONE,XF86MonBrightnessDown,spawn,noctalia msg brightness-down"

          # Media Playback
          "NONE,XF86AudioNext,spawn,noctalia msg media next"
          "NONE,XF86AudioPrev,spawn,noctalia msg media previous"
          "NONE,XF86AudioPlay,spawn,noctalia msg media toggle"

          # Custom Applications
          "SUPER,Return,spawn,kitty"
          "SUPER,e,spawn,dolphin"
          "SUPER,b,spawn,zen"
        ];

        # Mouse Bindings
        mousebind = [
          "SUPER,btn_left,moveresize,curmove"
          "SUPER,btn_right,moveresize,curresize"
          "SUPER+CTRL,btn_right,killclient"
          "SUPER+CTRL,btn_middle,togglefullscreen"
          "SUPER,btn_middle,togglemaximizescreen,0"
        ];

        source = [
          "./noctalia.conf"
          "./monitors.conf"
        ];
      };
    };
  };
}
