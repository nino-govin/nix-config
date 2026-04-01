{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mpv
    pavucontrol
  ];
}
