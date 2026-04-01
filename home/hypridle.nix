{ config, pkgs, ... }:

{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd   = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd          = "hyprlock";
      };

      listener = [
        {
          timeout    = 120;
          on-timeout = "brightnessctl -s set 0";
          on-resume  = "brightnessctl -r";
        }
        {
          timeout  = 180;
          on-timeout = "hyprlock";
        }
        {
          timeout  = 600;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
