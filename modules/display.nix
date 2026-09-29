{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    xkb.layout = "fr";
    xkb.variant = "";
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common = {
      default = [
        "hyprland"
        "gtk"
      ];
      "org.freedesktop.portal.OpenURI" = [ "gtk" ];
    };
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "greeter";
      command = "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%H:%M  %A %d %B' --greeting '  NixOS' --asterisks --user-menu --theme 'border=#4C566A;text=#D8DEE9;prompt=#88C0D0;time=#88C0D0;action=#81A1C1;button=#5E81AC;container=#3B4252;input=#434C5E' --sessions /run/current-system/sw/share/wayland-sessions --cmd start-hyprland";
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_DEVICE_PIXEL_RATIO = "1.6";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
  };
}
