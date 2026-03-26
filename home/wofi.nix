{ config, pkgs, ... }:

{
  programs.wofi = {
    enable = true;
    style = ''
      window {
        margin: 0;
        border: 2px solid #88c0d0;
        background-color: rgba(46, 52, 64, 0.95);
        border-radius: 8px;
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 14px;
      }

      #input {
        padding: 8px 12px;
        border: none;
        border-bottom: 1px solid #4c566a;
        background-color: transparent;
        color: #d8dee9;
        outline: none;
      }

      #inner-box {
        margin: 4px;
        background-color: transparent;
      }

      #entry {
        padding: 6px 12px;
        border-radius: 4px;
      }

      #entry:selected {
        background-color: #4c566a;
        color: #d8dee9;
      }

      #text {
        color: #d8dee9;
      }

      #text:selected {
        color: #88c0d0;
      }
    '';

    settings = {
      width        = 500;
      height       = 400;
      location     = "center";
      show         = "run";
      prompt       = "Lancer...";
      filter_rate  = 100;
      allow_markup = true;
      no_actions   = true;
      halign       = "fill";
      orientation  = "vertical";
      content_halign = "fill";
      insensitive  = true;
      allow_images = true;
      image_size   = 24;
    };
  };
}
