{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    awww
    grim slurp
    libnotify
    brightnessctl
    playerctl
    lxappearance qt6Packages.qt6ct libsForQt5.qt5ct
    wl-clipboard cliphist
    imagemagick
    xlsfonts
  ];
}
