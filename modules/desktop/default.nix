{ pkgs, ... }:

{
  imports = [
    ./display.nix
    ./greeter.nix
    ./fonts.nix
  ];

  environment.systemPackages = with pkgs; [
    grim
    slurp
    libnotify
    brightnessctl
    playerctl
    wl-clipboard
    cliphist
    imagemagick
    hyprshutdown
    cava
  ];
}
