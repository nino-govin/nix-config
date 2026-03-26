{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Barre de statut
    waybar

    # Lanceur d'applications
    wofi

    # Fond d'écran animé
    swww

    # Capture d'écran
    grim    # capture
    slurp   # sélection de zone

    # Verrouillage écran
    hyprlock hypridle

    # Notifications
    dunst
    libnotify  # commande notify-send

    # Luminosité
    brightnessctl

    # Volume / média
    playerctl   # contrôle lecture média
    pavucontrol

    # Thème et apparence
    lxappearance
    papirus-icon-theme
    arc-theme
    qt6Packages.qt6ct
    libsForQt5.qt5ct

    # Utilitaires Wayland
    wl-clipboard   # wl-copy / wl-paste
    cliphist       # historique presse-papier

    # Shell prompt
    starship

    # Terminal
    kitty

    # Divers
    imagemagick
    xlsfonts
  ];
}
