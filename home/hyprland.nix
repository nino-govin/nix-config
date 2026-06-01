{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable   = true;
    xwayland.enable = true;

    settings = {
      monitor = [
        "eDP-1,2560x1600@240,0x0,1.6"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,Adwaita"
      ];

      exec-once = [
        "swww-daemon"
        "swww img ~/Pictures/background.png"
        "nm-applet --indicator"
        "wl-paste --type text --watch cliphist store"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      ];

      input = {
        kb_layout    = "fr,us";
        follow_mouse = 1;
        sensitivity  = 0;
        touchpad = {
          natural_scroll   = false;
          tap-to-click     = true;
          drag_lock        = true;
        };
      };

      general = {
        gaps_in          = 5;
        gaps_out         = "4 8 8 8";
        border_size      = 2;
        "col.active_border"   = "rgba(88c0d0ff) rgba(5e81acff) 45deg";
        "col.inactive_border" = "rgba(3b4252ff)";
        layout           = "dwindle";
        resize_on_border = true;
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled  = true;
          size     = 6;
          passes   = 3;
          vibrancy = 0.17;
        };
        shadow = {
          enabled      = true;
          range        = 8;
          render_power = 3;
          color        = "rgba(1a1a1aee)";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "myBezier, 0.05, 0.9, 0.1, 1.05"
        ];
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile      = true;
        preserve_split  = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo   = true;
      };

      xwayland = {
        force_zero_scaling = true;
      };

      "$mod" = "SUPER";

      bind = [
        "$mod, Return, exec, kitty"
        "$mod, D, exec, wofi --show run"
        "$mod, E, exec, kitty -e yazi"
        "$mod, B, exec, firefox"

        "$mod SHIFT, Q, killactive"
        "$mod, F, fullscreen"
        "$mod SHIFT, space, togglefloating"
        "$mod, P, pseudo"
        "$mod, J, togglesplit"

        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"

        "$mod SHIFT, left,  movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up,    movewindow, u"
        "$mod SHIFT, down,  movewindow, d"

        "$mod, ampersand,  workspace, 1"
        "$mod, eacute,     workspace, 2"
        "$mod, quotedbl,   workspace, 3"
        "$mod, apostrophe, workspace, 4"
        "$mod, parenleft,  workspace, 5"
        "$mod, minus,      workspace, 6"
        "$mod, egrave,     workspace, 7"
        "$mod, underscore, workspace, 8"
        "$mod, ccedilla,   workspace, 9"
        "$mod, agrave,     workspace, 10"

        "$mod SHIFT, ampersand,  movetoworkspace, 1"
        "$mod SHIFT, eacute,     movetoworkspace, 2"
        "$mod SHIFT, quotedbl,   movetoworkspace, 3"
        "$mod SHIFT, apostrophe, movetoworkspace, 4"
        "$mod SHIFT, parenleft,  movetoworkspace, 5"
        "$mod SHIFT, minus,      movetoworkspace, 6"
        "$mod SHIFT, egrave,     movetoworkspace, 7"
        "$mod SHIFT, underscore, movetoworkspace, 8"
        "$mod SHIFT, ccedilla,   movetoworkspace, 9"
        "$mod SHIFT, agrave,     movetoworkspace, 10"

        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up,   workspace, e-1"

        "$mod SHIFT, S, exec, grim -g \"$(slurp)\" - | tee ~/Pictures/$(date +%Y%m%d_%H%M%S).png | wl-copy"
        ",Print, exec, grim - | tee ~/Pictures/$(date +%Y%m%d_%H%M%S).png | wl-copy"

        "$mod, space, exec, hyprctl switchxkblayout all next"

        "$mod SHIFT, L, exec, hyprlock"

	      "$mod SHIFT, E, exec, ~/.local/bin/power-menu"
      ];
	
      binde = [
        ",XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
        ",XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
        ",XF86AudioMute,        exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
        ",XF86AudioMicMute,     exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"

        ",XF86MonBrightnessUp,   exec, brightnessctl set +5%"
        ",XF86MonBrightnessDown, exec, brightnessctl set 5%-"

        ",XF86AudioPlay,  exec, playerctl play-pause"
        ",XF86AudioNext,  exec, playerctl next"
        ",XF86AudioPrev,  exec, playerctl previous"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      windowrulev2 = [
        "float, class:^(pavucontrol)$"
        "float, class:^(nm-connection-editor)$"
        "float, class:^(lxappearance)$"
        "float, title:^(Picture-in-Picture)$"
        "pin,   title:^(Picture-in-Picture)$"
        "nofocus, class:^(jetbrains-.*)$, title:^(win.*)$"
        "noinitialfocus, class:^(jetbrains-.*)$, title:^(win.*)$"
        "noanim, class:^(jetbrains-.*)$, title:^(win.*)$"
      ];
    };
  };
}
