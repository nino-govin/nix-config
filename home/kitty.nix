{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    settings = {
      background_opacity  = "0.92";
      background_blur     = 1;
      window_padding_width = 12;
      cursor_shape        = "block";
      cursor_blink_interval = "0.5";
      scrollback_lines    = 10000;
      copy_on_select      = "clipboard";

      # Thème Nord
      background  = "#2e3440";
      foreground  = "#d8dee9";
      color0      = "#3b4252";
      color1      = "#bf616a";
      color2      = "#a3be8c";
      color3      = "#ebcb8b";
      color4      = "#81a1c1";
      color5      = "#b48ead";
      color6      = "#88c0d0";
      color7      = "#e5e9f0";
      color8      = "#4c566a";
      color9      = "#bf616a";
      color10     = "#a3be8c";
      color11     = "#ebcb8b";
      color12     = "#81a1c1";
      color13     = "#b48ead";
      color14     = "#8fbcbb";
      color15     = "#eceff4";
    };
  };
}
