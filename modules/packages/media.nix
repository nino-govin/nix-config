{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mpv
    pavucontrol  # interface graphique PipeWire/PulseAudio
  ];
}
