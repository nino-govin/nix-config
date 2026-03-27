{ pkgs, ... }:

{
  # Steam avec support Wayland + Proton pour les jeux Windows
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  # Optimisations gaming
  programs.gamemode.enable = true;
}
