{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    waybar
    wofi
    awww
    grim slurp
    hyprlock hypridle
    dunst libnotify
    brightnessctl
    playerctl
    lxappearance papirus-icon-theme arc-theme qt6Packages.qt6ct libsForQt5.qt5ct
    wl-clipboard cliphist
    starship
    imagemagick
    xlsfonts
  ];
}
