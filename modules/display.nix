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
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # SDDM reste le display manager
  services.displayManager.sddm = {
    enable  = true;
    package = pkgs.kdePackages.sddm;
    wayland.enable = true;  # SDDM en mode Wayland
    settings = {
      General = { EnableHiDPI = true; };
    };
  };

  environment.sessionVariables = {
    # Forcer Wayland sur les apps compatibles
    NIXOS_OZONE_WL        = "1";   # Electron (VSCode, Discord...)
    QT_QPA_PLATFORM       = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_SCALE_FACTOR       = "1.5";
    GDK_SCALE             = "1.5";
    SDL_VIDEODRIVER       = "wayland";
    MOZ_ENABLE_WAYLAND    = "1";   # Firefox
    XDG_SESSION_TYPE      = "wayland";
    XDG_CURRENT_DESKTOP   = "Hyprland";
  };
}
