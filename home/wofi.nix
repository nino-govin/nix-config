{ config, pkgs, ... }:

{
  programs.wofi = {
    enable = true;
    style = ''
      window {
        margin: 0;
        border: 1px solid rgba(216, 222, 233, 0.16);
        background-color: rgba(46, 52, 64, 0.88);
        border-radius: 16px;
        font-family: "Manrope", sans-serif;
        font-size: 13px;
        color: #d8dee9;
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.7);
      }

      #input {
        margin: 8px 8px 4px 8px;
        padding: 8px 12px;
        border: 1px solid rgba(216, 222, 233, 0.16);
        border-radius: 7px;
        background-color: rgba(216, 222, 233, 0.06);
        color: #eceff4;
        outline: none;
        font-family: "Manrope", sans-serif;
        font-size: 13px;
      }

      #inner-box {
        margin: 4px 8px 8px 8px;
        background-color: transparent;
      }

      #outer-box {
        background-color: transparent;
      }

      #entry {
        padding: 6px 10px;
        border-radius: 5px;
      }

      #entry:selected {
        background-color: rgba(216, 222, 233, 0.10);
      }

      #text {
        color: #d8dee9;
        font-size: 13px;
      }

      #text:selected {
        color: #eceff4;
        font-weight: bold;
      }

      #img {
        margin-right: 6px;
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
