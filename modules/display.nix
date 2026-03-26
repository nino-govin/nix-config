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

  # SDDM reste le display manager
  services.displayManager.sddm = {
    enable  = true;
    package = pkgs.kdePackages.sddm;
    wayland.enable = true;  # SDDM en mode Wayland
    settings = {
      General = {
        EnableHiDPI = true;
        # QT_SCALE_FACTOR pour Qt6 (QT_SCREEN_SCALE_FACTORS est Qt5)
        GreeterEnvironment = "QT_SCALE_FACTOR=1.6";
      };
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
