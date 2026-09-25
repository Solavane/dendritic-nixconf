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
        systemctl --user start xdg-desktop-portal.service --ignore-dependencies #Screensharing fix until they update and fix this bs
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

          "SUPER,d,spawn,noctalia msg panel-toggle launcher"

          # Workspace Navigation
          "Super,1,view,1"
          "Super,2,view,2"
          "Super,3,view,3"
          "Super,4,view,4"
          "Super,5,view,5"
          "Super,6,view,6"
          "Super,7,view,7"
          "Super,8,view,8"
          "Super,9,view,9"

          # Move to Workspace
          "ctrl+Super,1,tag,1"
          "ctrl+Super,2,tag,2"
          "ctrl+Super,3,tag,3"
          "ctrl+Super,4,tag,4"
          "ctrl+Super,5,tag,5"
          "ctrl+Super,6,tag,6"
          "ctrl+Super,7,tag,7"
          "ctrl+Super,8,tag,8"
          "ctrl+Super,9,tag,9"

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
          "SHIFT,Print,spawn,$HOME/.config/mango/scripts/screenshot.sh fullscreen"
          "NONE,Print,spawn,$HOME/.config/mango/scripts/screenshot.sh region"
          "CTRL,Print,spawn,$HOME/.config/mango/scripts/screenshot.sh window"
          "SUPER,Print,spawn,$HOME/.config/mango/scripts/screenshot.sh annotate"

          # Volume Controls
          "NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_SINK@ 5%+"
          "NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_SINK@ 5%-"
          "NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_SINK@ toggle"
          "SHIFT,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_SOURCE@ toggle"

          # Media Playback
          "NONE,XF86AudioNext,spawn,playerctl next"
          "NONE,XF86AudioPrev,spawn,playerctl previous"
          "NONE,XF86AudioPlay,spawn,playerctl play-pause"

          # Theming
          "SUPER,w,spawn,wallpaper-menu"

          # Custom Applications
          "SUPER,Return,spawn,kitty"
          "SUPER,e,spawn,thunar"
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

        bottomPrefixes = [
        ];
      };
    };
  };
}
