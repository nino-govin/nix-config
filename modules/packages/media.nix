{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mpv
    pavucontrol
    ffmpeg-full
    scrcpy
    android-tools
  ];
}
