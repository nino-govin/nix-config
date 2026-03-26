{ config, pkgs, ... }:

{
  # Scripts custom GPU et stockage
  home.file.".local/bin/gpu-stats.sh" = {
    executable = true;
    source     = ./scripts/gpu-stats.sh;
  };
  home.file.".local/bin/storage.sh" = {
    executable = true;
    source     = ./scripts/storage.sh;
  };

  programs.waybar = {
    enable  = true;
    systemd.enable = true;  # waybar géré par systemd user, plus fiable que exec-once

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
        padding: 0;
        margin: 0;
      }

      window#waybar {
        background: transparent;
        color: #d8dee9;
      }

      /* Îlot générique */
      .island {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 10px;
      }

      /* Workspaces */
      #workspaces {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 6px;
      }

      #workspaces button {
        padding: 0 8px;
        color: #4c566a;
        background: transparent;
        border-radius: 8px;
        min-width: 24px;
      }

      #workspaces button.active {
        color: #88c0d0;
        background: rgba(88, 192, 208, 0.15);
      }

      #workspaces button.urgent {
        color: #bf616a;
        background: rgba(191, 97, 106, 0.15);
      }

      #workspaces button:hover {
        background: rgba(76, 86, 106, 0.3);
        color: #d8dee9;
      }

      /* Titre fenêtre */
      #window {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 14px;
        color: #d8dee9;
        font-style: italic;
      }

      /* Horloge */
      #clock {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(88, 192, 208, 0.4);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 16px;
        color: #88c0d0;
        font-weight: bold;
      }

      /* Stats système — îlot commun */
      #temperature, #cpu, #memory, #custom-gpu, #custom-storage {
        background: rgba(46, 52, 64, 0.88);
        border-radius: 0;
        margin: 6px 0;
        padding: 0 10px;
        color: #81a1c1;
      }

      /* Arrondi gauche du premier module de l'îlot stats */
      #temperature {
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-right: none;
        border-radius: 12px 0 0 12px;
        padding-left: 14px;
        color: #a3be8c;
      }

      #cpu {
        border-top: 1px solid rgba(76, 86, 106, 0.5);
        border-bottom: 1px solid rgba(76, 86, 106, 0.5);
      }

      #memory {
        border-top: 1px solid rgba(76, 86, 106, 0.5);
        border-bottom: 1px solid rgba(76, 86, 106, 0.5);
      }

      #custom-gpu {
        border-top: 1px solid rgba(76, 86, 106, 0.5);
        border-bottom: 1px solid rgba(76, 86, 106, 0.5);
        color: #b48ead;
      }

      /* Arrondi droit du dernier module de l'îlot stats */
      #custom-storage {
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-left: none;
        border-radius: 0 12px 12px 0;
        padding-right: 14px;
        color: #ebcb8b;
      }

      /* Îlot contrôles */
      #backlight, #pulseaudio, #network, #battery {
        background: rgba(46, 52, 64, 0.88);
        border-radius: 0;
        margin: 6px 0;
        padding: 0 10px;
      }

      #backlight {
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-right: none;
        border-radius: 12px 0 0 12px;
        padding-left: 14px;
        color: #ebcb8b;
      }

      #pulseaudio {
        border-top: 1px solid rgba(76, 86, 106, 0.5);
        border-bottom: 1px solid rgba(76, 86, 106, 0.5);
        color: #b48ead;
      }

      #pulseaudio.muted {
        color: #4c566a;
      }

      #network {
        border-top: 1px solid rgba(76, 86, 106, 0.5);
        border-bottom: 1px solid rgba(76, 86, 106, 0.5);
        color: #88c0d0;
      }

      #network.disconnected {
        color: #bf616a;
      }

      #battery {
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-left: none;
        border-radius: 0 12px 12px 0;
        padding-right: 14px;
        color: #a3be8c;
      }

      #battery.warning {
        color: #ebcb8b;
      }

      #battery.critical {
        color: #bf616a;
      }

      #battery.charging {
        color: #a3be8c;
      }

      /* Médias */
      #mpris {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(163, 190, 140, 0.4);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 14px;
        color: #a3be8c;
      }

      /* Tray */
      #tray {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 10px;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      /* États critiques température */
      #temperature.critical {
        color: #bf616a;
      }

      /* GPU états */
      #custom-gpu.high {
        color: #ebcb8b;
      }

      #custom-gpu.critical {
        color: #bf616a;
      }

      /* Stockage états */
      #custom-storage.warning {
        color: #ebcb8b;
      }

      #custom-storage.critical {
        color: #bf616a;
      }

      tooltip {
        background: rgba(36, 41, 54, 0.97);
        border: 1px solid rgba(88, 192, 208, 0.35);
        border-radius: 8px;
        color: #d8dee9;
        font-size: 12px;
      }
    '';

    settings = [{
      layer    = "top";
      position = "top";
      height   = 40;
      spacing  = 0;

      modules-left = [
        "hyprland/workspaces"
        "hyprland/window"
        "mpris"
      ];

      modules-center = [ "clock" ];

      modules-right = [
        "temperature"
        "cpu"
        "memory"
        "custom/gpu"
        "custom/storage"
        "backlight"
        "pulseaudio"
        "network"
        "battery"
        "tray"
      ];

      "hyprland/workspaces" = {
        format   = "{id}";
        on-click = "activate";
        sort-by-number = true;
      };

      "hyprland/window" = {
        max-length     = 60;
        separate-outputs = true;
      };

      mpris = {
        format         = "{player_icon} {title} — {artist}";
        format-paused  = "{status_icon} {title}";
        player-icons   = { default = ""; spotify = ""; };
        status-icons   = { paused = ""; };
        max-length     = 50;
        ignored-players = [ "firefox" ];
      };

      clock = {
        format         = " {:%Y-%m-%d   %H:%M}";
        tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
      };

      temperature = {
        thermal-zone       = 6;
        critical-threshold = 90;
        format             = " {temperatureC}°C";
        format-critical    = " {temperatureC}°C";
        tooltip            = false;
        interval           = 5;
      };

      cpu = {
        interval = 5;
        format   = " {usage}%";
        tooltip  = false;
      };

      memory = {
        interval = 10;
        format   = " {used:0.1f}G";
        tooltip-format = "RAM: {used:0.1f}G / {total:0.1f}G";
      };

      "custom/gpu" = {
        exec     = "~/.local/bin/gpu-stats.sh";
        interval = 5;
        return-type = "json";
        tooltip  = true;
      };

      "custom/storage" = {
        exec     = "~/.local/bin/storage.sh";
        interval = 30;
        return-type = "json";
        tooltip  = true;
      };

      backlight = {
        device       = "intel_backlight";
        format       = "{icon} {percent}%";
        format-icons = [ "" "" "" "" "" "" "" "" "" ];
        on-scroll-up   = "brightnessctl set +2%";
        on-scroll-down = "brightnessctl set 2%-";
        tooltip        = false;
      };

      pulseaudio = {
        format       = "{icon} {volume}%";
        format-muted = " muted";
        format-icons = { default = [ "" "" "" ]; };
        on-click       = "pavucontrol";
        on-scroll-up   = "pactl set-sink-volume @DEFAULT_SINK@ +2%";
        on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -2%";
        tooltip        = false;
      };

      network = {
        format-wifi        = " {essid}";
        format-ethernet    = " {ipaddr}";
        format-disconnected = "󰤭 off";
        tooltip-format-wifi = "{essid} — {signalStrength}%\n{ipaddr}";
        on-click           = "nm-connection-editor";
        interval           = 10;
      };

      battery = {
        states = { warning = 30; critical = 15; };
        format          = "{icon} {capacity}%";
        format-charging = " {capacity}%";
        format-icons    = [ "" "" "" "" "" ];
        tooltip-format  = "{timeTo}\n{power:.1f}W";
        interval        = 30;
      };

      tray = {
        spacing    = 8;
        icon-size  = 16;
      };
    }];
  };
}
