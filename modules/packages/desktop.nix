{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    grim
    slurp
    libnotify
    brightnessctl
    playerctl
    lxappearance
    wl-clipboard
    cliphist
    imagemagick
    hyprshutdown
    cava
    xlsfonts
  ];
}
