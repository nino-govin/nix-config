{ config, pkgs, ... }:

{
  home.file.".local/bin/adaptive-refresh-rate" = {
    source = ./scripts/adaptive-refresh-rate.sh;
    executable = true;
  };

  systemd.user.services.adaptive-refresh-rate = {
    Unit = {
      Description = "Adaptive refresh rate based on power state";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/.local/bin/adaptive-refresh-rate";
      Environment = "PATH=/run/current-system/sw/bin";
    };
  };

  systemd.user.timers.adaptive-refresh-rate = {
    Unit = {
      Description = "Timer for adaptive refresh rate";
    };

    Timer = {
      OnBootSec = "5s";
      OnUnitActiveSec = "10s";
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
