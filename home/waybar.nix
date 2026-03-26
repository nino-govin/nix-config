{ config, pkgs, ... }:

{
  home.file.".local/bin/cpu-stats.sh"  = { executable = true; source = ./scripts/cpu-stats.sh; };
  home.file.".local/bin/gpu-intel.sh"  = { executable = true; source = ./scripts/gpu-intel.sh; };
  home.file.".local/bin/gpu-nvidia.sh" = { executable = true; source = ./scripts/gpu-nvidia.sh; };
  home.file.".local/bin/storage.sh"    = { executable = true; source = ./scripts/storage.sh; };

  programs.waybar = {
    enable  = true;
    systemd.enable = true;

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

      /* ── Workspaces ───────────────────────────────────────────────────── */
      #workspaces {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 4px;
      }

      #workspaces button {
        padding: 0 5px;
        min-width: 18px;
        color: #4c566a;
        background: transparent;
        border-radius: 8px;
      }

      #workspaces button.active {
        color: #88c0d0;
        font-weight: bold;
        background: transparent;
      }

      #workspaces button.urgent {
        color: #bf616a;
      }

      #workspaces button:hover {
        color: #d8dee9;
        background: rgba(76, 86, 106, 0.2);
      }

      /* ── Titre fenêtre ───────────────────────────────────────────────── */
      #window {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 14px;
        color: #d8dee9;
        font-style: italic;
      }

      #window.empty {
        background: transparent;
        border-color: transparent;
        padding: 0;
        margin: 6px 0;
        min-width: 0;
      }

      /* ── Horloge ─────────────────────────────────────────────────────── */
      #clock {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(88, 192, 208, 0.4);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 16px;
        color: #88c0d0;
        font-weight: bold;
      }

      /* ── Médias ──────────────────────────────────────────────────────── */
      #mpris {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(163, 190, 140, 0.4);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 14px;
        color: #a3be8c;
      }

      /* ── Clavier (langue + capslock) — îlot indépendant ─────────────── */
      #language {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 12px;
        color: #d8dee9;
      }

      /* ── Îlot CPU (usage + température fusionnés) ───────────────────── */
      #custom-cpu-stats {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 14px;
        color: #81a1c1;
      }

      #custom-cpu-stats.critical {
        color: #bf616a;
      }

      /* ── Îlot GPU (Intel + NVIDIA) ───────────────────────────────────── */
      #custom-gpu-intel {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-right: none;
        border-radius: 12px 0 0 12px;
        margin: 6px 0 6px 4px;
        padding: 0 10px 0 14px;
        color: #88c0d0;
      }

      #custom-gpu-nvidia {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-left: none;
        border-radius: 0 12px 12px 0;
        margin: 6px 4px 6px 0;
        padding: 0 14px 0 10px;
        color: #b48ead;
      }

      #custom-gpu-nvidia.inactive {
        color: #4c566a;
      }

      #custom-gpu-nvidia.high {
        color: #ebcb8b;
      }

      #custom-gpu-nvidia.critical {
        color: #bf616a;
      }

      /* ── Îlot RAM + Stockage ─────────────────────────────────────────── */
      #memory {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-right: none;
        border-radius: 12px 0 0 12px;
        margin: 6px 0 6px 4px;
        padding: 0 10px 0 14px;
        color: #81a1c1;
      }

      #custom-storage {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-left: none;
        border-radius: 0 12px 12px 0;
        margin: 6px 4px 6px 0;
        padding: 0 14px 0 10px;
        color: #ebcb8b;
      }

      #custom-storage.warning { color: #ebcb8b; }
      #custom-storage.critical { color: #bf616a; }

      /* ── Îlot luminosité ─────────────────────────────────────────────── */
      #backlight {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 12px;
        color: #ebcb8b;
      }

      /* ── Îlot réseau ─────────────────────────────────────────────────── */
      #network {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 12px;
        color: #88c0d0;
      }

      #network.disconnected { color: #bf616a; }

      /* ── Îlot volume ─────────────────────────────────────────────────── */
      #pulseaudio {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 12px;
        color: #b48ead;
      }

      #pulseaudio.muted { color: #4c566a; }

      /* ── Îlot batterie ───────────────────────────────────────────────── */
      #battery {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 12px;
        color: #a3be8c;
      }

      #battery.warning  { color: #ebcb8b; }
      #battery.critical { color: #bf616a; }
      #battery.charging { color: #a3be8c; }

      /* ── Tray ────────────────────────────────────────────────────────── */
      #tray {
        background: rgba(46, 52, 64, 0.88);
        border: 1px solid rgba(76, 86, 106, 0.5);
        border-radius: 12px;
        margin: 6px 4px;
        padding: 0 10px;
      }

      #tray > .passive { -gtk-icon-effect: dim; }

      /* ── Tooltip global ──────────────────────────────────────────────── */
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
      height   = 36;
      spacing  = 0;

      modules-left = [
        "hyprland/workspaces"
        "hyprland/window"
      ];

      modules-center = [ "clock" ];

      modules-right = [
        "custom/cpu-stats"
        "custom/gpu-intel"
        "custom/gpu-nvidia"
        "memory"
        "custom/storage"
        "backlight"
        "pulseaudio"
        "battery"
        "tray"
      ];

      "hyprland/workspaces" = {
        format        = "{id}";
        on-click      = "activate";
        sort-by-number = true;
      };

      "hyprland/window" = {
        format           = "{}";
        rewrite          = { "^$" = ""; };
        separate-outputs = true;
        max-length       = 60;
      };

      clock = {
        format         = "󰃭 {:%Y-%m-%d   %H:%M}";
        tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
      };

      "custom/cpu-stats" = {
        exec        = "~/.local/bin/cpu-stats.sh";
        interval    = 5;
        return-type = "json";
        format      = "CPU 󰻠 {}";
        tooltip     = true;
      };

      "custom/gpu-intel" = {
        exec        = "~/.local/bin/gpu-intel.sh";
        interval    = 5;
        return-type = "json";
        format      = "GPU 󰘚 {}";
        tooltip     = true;
      };

      "custom/gpu-nvidia" = {
        exec        = "~/.local/bin/gpu-nvidia.sh";
        interval    = 5;
        return-type = "json";
        format      = "󰊴 {}";
        tooltip     = true;
      };

      memory = {
        interval       = 10;
        format         = "󰍛 {used:0.1f}G";
        tooltip-format = "RAM: {used:0.1f}G / {total:0.1f}G";
      };

      "custom/storage" = {
        exec        = "~/.local/bin/storage.sh";
        interval    = 30;
        return-type = "json";
        format      = "󰋊 {}";
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

      network = {
        format-wifi         = "󰖩";
        format-ethernet     = "󰈀";
        format-disconnected = "󰤭";
        tooltip-format-wifi     = "{essid} — {signalStrength}%\n{ipaddr}";
        tooltip-format-ethernet = "{ipaddr}";
        on-click                = "nm-connection-editor";
        interval                = 10;
      };

      battery = {
        states           = { warning = 30; critical = 15; };
        format           = "{icon} Discharging {capacity}%";
        format-charging  = "󰂄 Charging {capacity}%";
        format-plugged   = "󰁹 Plugged {capacity}%";
        format-full      = "󰁹 Full";
        format-icons     = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        tooltip-format   = "{timeTo}\n{power:.1f}W";
        interval         = 30;
      };

      tray = {
        spacing   = 8;
        icon-size = 16;
      };
    }];
  };
}
