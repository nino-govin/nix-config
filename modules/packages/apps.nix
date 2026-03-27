{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Bureautique
    libreoffice
    zathura
    obsidian

    # Réseau et intégration desktop
    xdg-utils xdg-desktop-portal networkmanagerapplet gnome-keyring

    # Communication
    discord

    # Jeux
    moonlight-qt osu-lazer
  ];
}
