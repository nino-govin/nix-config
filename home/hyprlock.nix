{ config, pkgs, ... }:

{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = false;
        hide_cursor         = true;
        grace               = 0;
      };

      background = [{
        path         = "~/Pictures/background.png";
        blur_passes  = 3;
        blur_size    = 8;
        brightness   = 0.6;
      }];

      input-field = [{
        size              = "300, 50";
        position          = "0, -100";
        halign            = "center";
        valign            = "center";
        outline_thickness = 2;
        dots_size         = 0.33;
        dots_spacing      = 0.15;
        outer_color       = "rgb(88c0d0)";
        inner_color       = "rgb(46, 52, 64)";
        font_color        = "rgb(216, 222, 233)";
        fade_on_empty     = true;
        placeholder_text  = "<i>Mot de passe...</i>";
        shadow_passes     = 2;
      }];

      label = [
        {
          text      = "cmd[update:1000] echo \"$(date +'%H:%M')\"";
          color     = "rgba(216, 222, 233, 0.9)";
          font_size = 72;
          position  = "0, 80";
          halign    = "center";
          valign    = "center";
        }
        {
          text      = "cmd[update:60000] echo \"$(date +'%A %d %B %Y')\"";
          color     = "rgba(136, 192, 208, 0.8)";
          font_size = 20;
          position  = "0, 0";
          halign    = "center";
          valign    = "center";
        }
        {
          text      = "Layout: $LAYOUT[FR,EN]";
          color     = "rgba(136, 192, 208, 0.8)";
          font_size = 16;
          position  = "30, 30";
          halign    = "left";
          valign    = "bottom";
        }
      ];
    };
  };
}
