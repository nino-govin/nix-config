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
          # Éteindre l'écran après 2 minutes d'inactivité
          timeout    = 120;
          on-timeout = "brightnessctl -s set 0";
          on-resume  = "brightnessctl -r";
        }
        {
          # Verrouiller après 5 minutes
          timeout  = 180;
          on-timeout = "hyprlock";
        }
        {
          # Suspendre après 10 minutes
          timeout  = 600;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
