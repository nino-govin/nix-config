rec {
  user = "nino-nixos";

  monitor = {
    output = "eDP-1";
    resolution = "2560x1600";
    position = "0x0";
    scale = "1.6";
    refresh = {
      max = 240;
      min = 60;
    };
  };

  monitorLua =
    rate:
    ''hl.monitor({ output = "${monitor.output}", mode = "${monitor.resolution}@${toString rate}", position = "${monitor.position}", scale = ${monitor.scale} })'';
}
