{
  lib,
  pkgs,
  host,
  osConfig,
  ...
}:

let
  hyprctl = osConfig.programs.hyprland.package;
  profileFile = ''"''${XDG_DATA_HOME:-$HOME/.local/share}/power-profile"'';

  adaptiveRefreshRate = pkgs.writeShellApplication {
    name = "adaptive-refresh-rate";
    runtimeInputs = [
      hyprctl
      pkgs.procps
    ];
    text = ''
      profile=$(cat ${profileFile} 2>/dev/null || echo balanced)
      [ "$profile" = balanced ] || exit 0

      if pgrep -x "osu!.exe" >/dev/null || pgrep -x wine >/dev/null; then
        exit 0
      fi

      for ac in /sys/class/power_supply/AC*/online /sys/class/power_supply/ADP*/online; do
        if [ -f "$ac" ] && [ "$(cat "$ac")" = 1 ]; then
          hyprctl eval '${host.monitorLua host.monitor.refresh.max}'
          exit 0
        fi
      done

      hyprctl eval '${host.monitorLua host.monitor.refresh.min}'
    '';
  };

  setPowerProfile = pkgs.writeShellApplication {
    name = "set-power-profile";
    runtimeInputs = [ hyprctl ];
    text = ''
      mode="''${1:-}"
      case "$mode" in
        performance | balanced | economy) ;;
        *) exit 1 ;;
      esac

      /run/wrappers/bin/sudo /run/current-system/sw/bin/power-profile-apply "$mode"
      echo "$mode" >${profileFile}

      visuals() {
        hyprctl eval "hl.config({ animations = { enabled = $1 }, decoration = { blur = { enabled = $1 }, shadow = { enabled = $1 } } })"
      }

      case "$mode" in
        performance)
          hyprctl eval '${host.monitorLua host.monitor.refresh.max}'
          visuals true
          ;;
        balanced)
          ${lib.getExe adaptiveRefreshRate}
          visuals true
          ;;
        economy)
          hyprctl eval '${host.monitorLua host.monitor.refresh.min}'
          visuals false
          ;;
      esac
    '';
  };
in
{
  home.file.".local/bin/set-power-profile".source = lib.getExe setPowerProfile;

  systemd.user.services.adaptive-refresh-rate = {
    Unit = {
      Description = "Adaptive refresh rate based on power state";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe adaptiveRefreshRate;
    };
  };

  systemd.user.timers.adaptive-refresh-rate = {
    Unit = {
      Description = "Timer for adaptive refresh rate";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Timer = {
      OnBootSec = "30s";
      OnUnitActiveSec = "10s";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
