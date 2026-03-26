{ config, pkgs, ... }:

{
  # Xserver reste nécessaire pour le clavier et XWayland
  services.xserver = {
    enable = true;
    xkb.layout  = "fr";
    xkb.variant = "";
    # i3 supprimé
  };

  # Hyprland
  programs.hyprland = {
    enable        = true;
    xwayland.enable = true;  # compatibilité apps X11
  };

  # Portail desktop requis pour Hyprland (partage d'écran, fichiers, etc.)
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk  # file picker GTK (dialogs de téléchargement)
    ];
  };

  # greetd + tuigreet : greeter natif Wayland, pas de flash TTY, pas de scaling Qt
  services.greetd = {
    enable = true;
    settings.default_session = {
      user    = "greeter";
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%H:%M  %A %d %B' --greeting '  NixOS' --asterisks --user-menu --theme 'border=#4C566A;text=#D8DEE9;prompt=#88C0D0;time=#88C0D0;action=#81A1C1;button=#5E81AC;container=#3B4252;input=#434C5E' --sessions /run/current-system/sw/share/wayland-sessions --cmd Hyprland";
    };
  };


  environment.sessionVariables = {
    # Forcer Wayland sur les apps compatibles
    NIXOS_OZONE_WL        = "1";   # Electron (VSCode, Discord...)
    QT_QPA_PLATFORM       = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # GDK_SCALE et QT_SCALE_FACTOR supprimés : le protocole Wayland gère
    # déjà le scale (1.6×) — les définir provoquait un double scaling
    SDL_VIDEODRIVER       = "wayland";
    MOZ_ENABLE_WAYLAND    = "1";   # Firefox
    MOZ_DEVICE_PIXEL_RATIO = "1.6"; # Firefox : force le pixel ratio fractionnaire
    XDG_SESSION_TYPE      = "wayland";
    XDG_CURRENT_DESKTOP   = "Hyprland";
  };
}
