{ config, lib, pkgs, ... }:

let
  user = "nino-nixos";
  stateDir = "/var/lib/jaqc-greeter";
  hyprland = config.programs.hyprland.package;

  session = pkgs.writeShellScript "jaqc-greeter-session" ''
    export HOME=${stateDir}
    export XDG_CONFIG_HOME=${stateDir}
    export TZDIR=/etc/zoneinfo
    export XDG_CACHE_HOME=/tmp/jaqc-greeter/cache
    export XDG_STATE_HOME=/tmp/jaqc-greeter/state
    export USER=${user}
    export GREETER_USER=${user}
    export GREETER_SESSION=start-hyprland
    ${pkgs.quickshell}/bin/qs -p /etc/nixos/home/quickshell/greeter.qml
    ${hyprland}/bin/hyprctl dispatch 'hl.dsp.exit()'
  '';

  hyprlandConfig = pkgs.writeText "jaqc-greeter.lua" ''
    hl.monitor({ output = "eDP-1", mode = "2560x1600@240", position = "0x0", scale = 1.6 })
    hl.env("XCURSOR_SIZE", "24")
    hl.env("XCURSOR_THEME", "Adwaita")
    hl.config({
      input = { kb_layout = "fr,us" },
      animations = { enabled = false },
      misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
      },
    })
    hl.on("hyprland.start", function()
      hl.exec_cmd("${session}")
    end)
  '';

  tuigreet = "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%H:%M  %A %d %B' --greeting '  NixOS' --asterisks --user-menu --theme 'border=#4C566A;text=#D8DEE9;prompt=#88C0D0;time=#88C0D0;action=#81A1C1;button=#5E81AC;container=#3B4252;input=#434C5E' --sessions /run/current-system/sw/share/wayland-sessions --cmd start-hyprland";
in
{
  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "greeter";
      command = "${hyprland}/bin/start-hyprland -- --config ${hyprlandConfig}";
    };
  };

  systemd.tmpfiles.rules = [ "d ${stateDir} 0755 ${user} users -" ];

  specialisation.tuigreet.configuration.services.greetd.settings.default_session.command = lib.mkForce tuigreet;
}
