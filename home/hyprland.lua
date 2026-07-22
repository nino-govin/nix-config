hl.monitor({ output = "eDP-1", mode = "2560x1600@240", position = "0x0", scale = 1.6 })

hl.env("XCURSOR_SIZE",              "24")
hl.env("XCURSOR_THEME",             "Adwaita")
hl.env("LIBVA_DRIVER_NAME",         "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

hl.on("hyprland.start", function()
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("awww img ~/Pictures/background.png")
  hl.exec_cmd("nm-applet --indicator")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
end)

hl.config({
  input = {
    kb_layout    = "fr,us",
    follow_mouse = 1,
    sensitivity  = 0,
    touchpad = {
      natural_scroll = false,
      tap_to_click   = true,
      drag_lock      = 1,
    },
  },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.config({
  general = {
    gaps_in      = 5,
    gaps_out     = 8,
    border_size  = 2,
    ["col.active_border"]   = { colors = { "rgba(88c0d0ff)", "rgba(5e81acff)" }, angle = 45 },
    ["col.inactive_border"] = "rgba(3b4252ff)",
    layout           = "dwindle",
    resize_on_border = true,
  },
})

hl.config({
  decoration = {
    rounding = 8,
    blur = {
      enabled  = true,
      size     = 6,
      passes   = 3,
      vibrancy = 0.17,
    },
    shadow = {
      enabled      = true,
      range        = 8,
      render_power = 3,
      color        = "rgba(1a1a1aee)",
    },
  },
})

hl.config({ animations = { enabled = true } })
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default",  style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })

hl.config({ dwindle = { preserve_split = true } })

hl.config({
  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo   = true,
  },
})

hl.config({ xwayland = { force_zero_scaling = true } })

local mod = "SUPER"

hl.bind(mod .. " + Return",        hl.dsp.exec_cmd("kitty"))
hl.bind(mod .. " + D",             hl.dsp.exec_cmd("wofi --show run"))
hl.bind(mod .. " + E",             hl.dsp.exec_cmd("kitty -e yazi"))
hl.bind(mod .. " + B",             hl.dsp.exec_cmd("firefox"))

hl.bind(mod .. " + SHIFT + Q",     hl.dsp.window.close())
hl.bind(mod .. " + F",             hl.dsp.window.fullscreen())
hl.bind(mod .. " + SHIFT + space", hl.dsp.window.float())
hl.bind(mod .. " + P",             hl.dsp.window.pseudo())
hl.bind(mod .. " + J",             hl.dsp.layout("togglesplit"))

hl.bind(mod .. " + left",          hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + right",         hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + up",            hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + down",          hl.dsp.focus({ direction = "d" }))

hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

hl.bind(mod .. " + ampersand",  hl.dsp.focus({ workspace = 1  }))
hl.bind(mod .. " + eacute",     hl.dsp.focus({ workspace = 2  }))
hl.bind(mod .. " + quotedbl",   hl.dsp.focus({ workspace = 3  }))
hl.bind(mod .. " + apostrophe", hl.dsp.focus({ workspace = 4  }))
hl.bind(mod .. " + parenleft",  hl.dsp.focus({ workspace = 5  }))
hl.bind(mod .. " + minus",      hl.dsp.focus({ workspace = 6  }))
hl.bind(mod .. " + egrave",     hl.dsp.focus({ workspace = 7  }))
hl.bind(mod .. " + underscore", hl.dsp.focus({ workspace = 8  }))
hl.bind(mod .. " + ccedilla",   hl.dsp.focus({ workspace = 9  }))
hl.bind(mod .. " + agrave",     hl.dsp.focus({ workspace = 10 }))

hl.bind(mod .. " + SHIFT + ampersand",  hl.dsp.window.move({ workspace = 1  }))
hl.bind(mod .. " + SHIFT + eacute",     hl.dsp.window.move({ workspace = 2  }))
hl.bind(mod .. " + SHIFT + quotedbl",   hl.dsp.window.move({ workspace = 3  }))
hl.bind(mod .. " + SHIFT + apostrophe", hl.dsp.window.move({ workspace = 4  }))
hl.bind(mod .. " + SHIFT + parenleft",  hl.dsp.window.move({ workspace = 5  }))
hl.bind(mod .. " + SHIFT + minus",      hl.dsp.window.move({ workspace = 6  }))
hl.bind(mod .. " + SHIFT + egrave",     hl.dsp.window.move({ workspace = 7  }))
hl.bind(mod .. " + SHIFT + underscore", hl.dsp.window.move({ workspace = 8  }))
hl.bind(mod .. " + SHIFT + ccedilla",   hl.dsp.window.move({ workspace = 9  }))
hl.bind(mod .. " + SHIFT + agrave",     hl.dsp.window.move({ workspace = 10 }))

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | tee ~/Pictures/$(date +%Y%m%d_%H%M%S).png | wl-copy'))
hl.bind("Print",               hl.dsp.exec_cmd('grim - | tee ~/Pictures/$(date +%Y%m%d_%H%M%S).png | wl-copy'))

hl.bind(mod .. " + space",     hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))
hl.bind(mod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("quickshell ipc call showPowerMenu show"))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"),      { repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"),      { repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), { locked = true })

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

hl.layer_rule({ match = { namespace = "quickshell-rail" },     blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ match = { namespace = "quickshell-topbar" },   blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "quickshell-qs" },       blur = true, ignore_alpha = 0.2, blur_popups = true })
hl.layer_rule({ match = { namespace = "quickshell-powermenu"}, blur = true, ignore_alpha = 0.2, dim_around = true })
hl.layer_rule({ match = { namespace = "quickshell-notifs" },   blur = true, ignore_alpha = 0.2 })

hl.window_rule({ match = { class = "^pavucontrol$" },          float = true })
hl.window_rule({ match = { class = "^nm-connection-editor$" }, float = true })
hl.window_rule({ match = { class = "^lxappearance$" },         float = true })
hl.window_rule({ match = { title = "^Picture-in-Picture$" },   float = true })
hl.window_rule({ match = { title = "^Picture-in-Picture$" },   pin   = true })
hl.window_rule({ match = { class = "^jetbrains-", title = "^win" }, no_focus         = true })
hl.window_rule({ match = { class = "^jetbrains-", title = "^win" }, no_initial_focus = true })
hl.window_rule({ match = { class = "^jetbrains-", title = "^win" }, no_anim          = true })
