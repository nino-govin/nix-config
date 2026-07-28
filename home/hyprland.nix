{ lib, ... }:

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
      require("config")
    '';
  };

  xdg.configFile."hypr/config.lua".source = ./hyprland.lua;

  home.activation.removeHyprlandConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    conf="$HOME/.config/hypr/hyprland.conf"
    [ -f "$conf" ] && [ ! -L "$conf" ] && rm -f "$conf" || true
  '';
}
