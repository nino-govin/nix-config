{
  name     = "top";
  layer    = "top";
  position = "top";
  height   = 36;
  spacing  = 0;

  modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
  modules-center = [ "clock" ];
  modules-right  = [
    "custom/keyboard-layout"
    "backlight"
    "pulseaudio"
    "battery"
    "tray"
  ];

  "hyprland/workspaces" = {
    format         = "{id}";
    on-click       = "activate";
    sort-by-number = true;
  };

  "hyprland/window" = {
    format           = "{}";
    rewrite          = { "^$" = "ദ്ദി/ᐠ｡‸｡ᐟ\\"; };
    separate-outputs = true;
    max-length       = 60;
  };

  clock = {
    format         = "󰃭 {:%Y-%m-%d   %H:%M}";
    tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
  };

  "custom/keyboard-layout" = {
    exec        = "~/.local/bin/keyboard-layout.sh";
    interval    = 1;
    return-type = "json";
    format      = "󰌌 {}";
    on-click    = "hyprctl switchxkblayout all next";
    tooltip     = true;
  };

  backlight = {
    device         = "intel_backlight";
    format         = "󰖨 {percent}%";
    on-scroll-up   = "brightnessctl set +2%";
    on-scroll-down = "sh -c 'brightnessctl set 2%-; [ $(brightnessctl get) -eq 0 ] && brightnessctl set 1'";
    tooltip        = false;
  };

  pulseaudio = {
    format         = "{icon} {volume}%";
    format-muted   = "󰝟 muted";
    format-icons   = { default = [ "󰕿" "󰖀" "󰕾" ]; };
    on-click       = "pavucontrol";
    on-scroll-up   = "wpctl set-volume @DEFAULT_SINK@ 2%+";
    on-scroll-down = "wpctl set-volume @DEFAULT_SINK@ 2%-";
    tooltip        = false;
  };

  battery = {
    states          = { warning = 30; critical = 15; };
    format          = "{icon} {capacity}%";
    format-charging = "󰂄 {capacity}%";
    format-plugged  = "󰁹 {capacity}%";
    format-full     = "󰁹 Full";
    format-icons    = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
    tooltip-format  = "{timeTo}\n{power:.1f}W";
    interval        = 30;
  };

  tray = {
    spacing   = 8;
    icon-size = 16;
  };
}
