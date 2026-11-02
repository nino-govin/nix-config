{
  config,
  lib,
  host,
  ...
}:

let
  cursor = config.home.pointerCursor;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    package = null;
    portalPackage = null;
    xwayland.enable = true;

    systemd = {
      enable = true;
      variables = [ "--all" ];
    };

    extraConfig = ''
      ${host.monitorLua host.monitor.refresh.max}
      hl.env("XCURSOR_THEME", "${cursor.name}")
      hl.env("XCURSOR_SIZE", "${toString cursor.size}")
      require("config")
    '';
  };

  xdg.configFile."hypr/config.lua".source = ./hyprland.lua;

  home.activation.removeHyprlandConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    conf="$HOME/.config/hypr/hyprland.conf"
    [ -f "$conf" ] && [ ! -L "$conf" ] && rm -f "$conf" || true
  '';
}
