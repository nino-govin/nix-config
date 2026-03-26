{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Bureautique
    libreoffice
    zathura

    # Réseau et intégration desktop
    xdg-utils xdg-desktop-portal networkmanagerapplet gnome-keyring

    # Communication
    discord

    # Jeux
    moonlight-qt
  ];
}
