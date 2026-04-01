{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    obsidian
    xdg-utils xdg-desktop-portal networkmanagerapplet gnome-keyring
    discord
    moonlight-qt protonup-qt
  ];
}
