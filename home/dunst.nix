{ config, pkgs, ... }:

{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor              = 0;
        follow               = "mouse";
        width                = 350;
        height               = 200;
        origin               = "top-right";
        offset               = "12x48";
        scale                = 0;
        notification_limit   = 5;
        progress_bar         = true;
        indicate_hidden      = true;
        transparency         = 8;
        separator_height     = 2;
        padding              = 10;
        horizontal_padding   = 12;
        frame_width          = 2;
        frame_color          = "#88c0d0";
        corner_radius        = 6;
        sort                 = "yes";
        font                 = "JetBrainsMono Nerd Font 11";
        line_height          = 0;
        markup               = "full";
        format               = "<b>%s</b>\n%b";
        alignment            = "left";
        icon_position        = "left";
        min_icon_size        = 24;
        max_icon_size        = 32;
        icon_theme           = "Papirus-Dark";
        enable_recursive_icon_lookup = true;
        browser              = "firefox";
      };

      urgency_low = {
        background = "#2e3440";
        foreground = "#d8dee9";
        timeout    = 5;
      };

      urgency_normal = {
        background = "#3b4252";
        foreground = "#d8dee9";
        timeout    = 8;
      };

      urgency_critical = {
        background = "#bf616a";
        foreground = "#eceff4";
        frame_color = "#ebcb8b";
        timeout    = 0;
      };
    };
  };
}
