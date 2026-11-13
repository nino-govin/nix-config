hl.on("hyprland.start", function()
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
hl.gesture({ fingers = 3, direction = "up", action = function() hl.exec_cmd("qs ipc call gesture swipeUp") end })
hl.gesture({ fingers = 3, direction = "down", action = function() hl.exec_cmd("qs ipc call gesture swipeDown") end })

hl.config({
  general = {
    gaps_in      = 5,
    gaps_out     = 8,
    border_size  = 0,
    layout           = "dwindle",
    resize_on_border = true,
    allow_tearing    = true,
  },
})

hl.config({
  decoration = {
    rounding       = 12,
    rounding_power = 2.5,
    blur = {
      enabled    = true,
      size       = 5,
      passes     = 3,
      noise      = 0.02,
      contrast   = 0.9,
      brightness = 0.85,
      vibrancy   = 0.1,
    },
    shadow = {
      enabled        = true,
      range          = 28,
      render_power   = 4,
      offset         = { 0, 6 },
      color          = "rgba(00000070)",
      color_inactive = "rgba(00000040)",
    },
  },
})

hl.config({ animations = { enabled = true } })
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.curve("easeInQuart",  { type = "bezier", points = { {0.5, 0}, {0.75, 0} } })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3,   bezier = "easeOutQuint", style = "popin 92%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 1.8, bezier = "easeInQuart",  style = "popin 92%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.8, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeIn",      enabled = true, speed = 2.5, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 1.8, bezier = "easeInQuart" })
hl.animation({ leaf = "fadeSwitch",  enabled = true, speed = 2.5, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeShadow",  enabled = true, speed = 2.5, bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 3.5, bezier = "easeOutQuint", style = "slidefade 15%" })
hl.animation({ leaf = "border",      enabled = false })
hl.animation({ leaf = "borderangle", enabled = false })

hl.config({ dwindle = { preserve_split = true } })

hl.config({
  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo   = true,
    vrr                     = 1,
  },
})

hl.config({ xwayland = { force_zero_scaling = true } })

local mod = "SUPER"

hl.bind(mod .. " + Return",        hl.dsp.exec_cmd("kitty"), { description = "Apps: Terminal" })
hl.bind(mod .. " + D",             hl.dsp.exec_cmd("qs ipc call launcher toggle"), { description = "Shell: App launcher" })
hl.bind(mod .. " + E",             hl.dsp.exec_cmd("kitty -e yazi"), { description = "Apps: File manager" })
hl.bind(mod .. " + B",             hl.dsp.exec_cmd("firefox"), { description = "Apps: Browser" })

hl.bind(mod .. " + SHIFT + Q",     hl.dsp.window.close(), { description = "Windows: Close" })
hl.bind(mod .. " + F",             hl.dsp.window.fullscreen(), { description = "Windows: Fullscreen" })
hl.bind(mod .. " + SHIFT + space", hl.dsp.window.float(), { description = "Windows: Toggle floating" })
hl.bind(mod .. " + P",             hl.dsp.window.pseudo(), { description = "Windows: Pseudo-tile" })
hl.bind(mod .. " + J",             hl.dsp.layout("togglesplit"), { description = "Windows: Toggle split" })

hl.bind(mod .. " + left",          hl.dsp.focus({ direction = "l" }), { description = "Focus: Left" })
hl.bind(mod .. " + right",         hl.dsp.focus({ direction = "r" }), { description = "Focus: Right" })
hl.bind(mod .. " + up",            hl.dsp.focus({ direction = "u" }), { description = "Focus: Up" })
hl.bind(mod .. " + down",          hl.dsp.focus({ direction = "d" }), { description = "Focus: Down" })

hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }), { description = "Windows: Move left" })
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }), { description = "Windows: Move right" })
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }), { description = "Windows: Move up" })
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }), { description = "Windows: Move down" })

local workspace_keys = {
  "ampersand", "eacute", "quotedbl", "apostrophe", "parenleft",
  "minus", "egrave", "underscore", "ccedilla", "agrave",
}

for i, key in ipairs(workspace_keys) do
  hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }),       { description = "Workspaces: Focus workspace " .. i })
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { description = "Workspaces: Move window to " .. i })
end

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Workspaces: Next" })
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { description = "Workspaces: Previous" })

hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("screenshot area"), { description = "Shell: Screenshot area" })
hl.bind("Print",               hl.dsp.exec_cmd("screenshot screen"), { description = "Shell: Screenshot screen" })

hl.bind(mod .. " + space",     hl.dsp.exec_cmd("hyprctl switchxkblayout all next"), { description = "Shell: Next keyboard layout" })
hl.bind(mod .. " + SHIFT + L", hl.dsp.exec_cmd("qs ipc call lockscreen lock"), { description = "Shell: Lock screen" })
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("qs ipc call powermenu toggle"), { description = "Shell: Power menu" })
hl.bind(mod .. " + W",         hl.dsp.exec_cmd("qs ipc call wallpaper toggle"), { description = "Shell: Wallpapers" })
hl.bind(mod .. " + F1",        hl.dsp.exec_cmd("qs ipc call keybinds toggle"), { description = "Shell: Keybind cheatsheet" })
hl.bind(mod .. " + V",         hl.dsp.exec_cmd("qs ipc call launcher showClipboard"), { description = "Shell: Clipboard history" })

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Mouse: Move window" })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Mouse: Resize window" })

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("qs ipc call audio raise"), { repeating = true, description = "Media: Volume up" })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("qs ipc call audio lower"), { repeating = true, description = "Media: Volume down" })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("qs ipc call audio toggleMute"), { locked = true, description = "Media: Mute" })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("qs ipc call audio toggleMicMute"), { locked = true, description = "Media: Mute microphone" })

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("qs ipc call brightness raise"), { repeating = true, description = "Media: Brightness up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("qs ipc call brightness lower"), { repeating = true, description = "Media: Brightness down" })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Media: Play / pause" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "Media: Next track" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, description = "Media: Previous track" })

hl.layer_rule({ match = { namespace = "^(quickshell|status-bar|wallpaper|wallpaper-picker|floating-widgets|lock-transition)$" }, no_anim = true })

hl.window_rule({ match = { title = "^(Quickshell Settings|Crop profile picture)$" }, float = true })
hl.window_rule({ match = { title = "^Crop profile picture$" }, center = true })
hl.window_rule({ match = { class = "^pavucontrol$" },          float = true })
hl.window_rule({ match = { class = "^nm-connection-editor$" }, float = true })
hl.window_rule({ match = { title = "^Picture-in-Picture$" },   float = true, pin = true })
hl.window_rule({ match = { class = "^jetbrains-", title = "^win" }, no_focus = true, no_initial_focus = true, no_anim = true })
hl.window_rule({ match = { class = "^osu!\\.exe$", title = "^osu!$" }, no_anim = true, immediate = true })
hl.window_rule({
  match = {
    class = "^osu!\\.exe$",
    title = "Setup|Timing|Design|Options|Compose",
  },
  float  = true,
  center = true,
  size   = "800 600",
})
