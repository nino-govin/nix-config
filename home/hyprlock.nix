{ config, pkgs, ... }:

{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
        grace = 0;
      };

      background = [
        {
          path = "~/Pictures/background.png";
          blur_passes = 3;
          blur_size = 7;
          brightness = 0.55;
        }
      ];

      input-field = [
        {
          size = "420, 64";
          position = "0, -80";
          halign = "center";
          valign = "center";
          outline_thickness = 2;
          dots_size = 0.30;
          dots_spacing = 0.18;
          outer_color = "rgba(129, 161, 193, 0.8)";
          inner_color = "rgba(46, 52, 64, 0.75)";
          font_color = "rgb(216, 222, 233)";
          font_family = "Manrope";
          fade_on_empty = true;
          placeholder_text = "<span foreground='##7d879e'><i>Mot de passe</i></span>";
          fail_color = "rgba(191, 97, 106, 0.8)";
          fail_text = "<span foreground='##d99aa1'><i>Mot de passe incorrect</i></span>";
          fail_transition = 200;
          rounding = 10;
          shadow_passes = 2;
          shadow_color = "rgba(0, 0, 0, 0.45)";
        }
      ];

      label = [
        {
          text = "cmd[update:1000] date +'%H:%M'";
          color = "rgba(236, 239, 244, 0.95)";
          font_size = 90;
          font_family = "Manrope";
          position = "0, 160";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
          shadow_color = "rgba(0, 0, 0, 0.4)";
        }
        {
          text = "cmd[update:60000] date +'%A %d %B %Y'";
          color = "rgba(166, 172, 205, 0.85)";
          font_size = 20;
          font_family = "Manrope";
          position = "0, 76";
          halign = "center";
          valign = "center";
        }
        {
          text = "$LAYOUT[FR,EN]";
          color = "rgba(166, 172, 205, 0.7)";
          font_size = 20;
          font_family = "Manrope";
          position = "24, 24";
          halign = "left";
          valign = "bottom";
        }
        {
          text = "cmd[update:30000] cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1 | xargs -r printf '%s%%'";
          color = "rgba(163, 190, 140, 0.7)";
          font_size = 20;
          font_family = "Manrope";
          position = "-24, 24";
          halign = "right";
          valign = "bottom";
        }
      ];
    };
  };
}
