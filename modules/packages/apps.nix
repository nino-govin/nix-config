{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    obsidian
    xdg-utils
    discord
    moonlight-qt protonup-qt
  ];
}
