{ pkgs, ... }:

{
  # Steam avec support Wayland + Proton pour les jeux Windows
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  # Support graphique 32-bit + Vulkan (requis pour DXVK/Proton)
  hardware.graphics = {
    enable     = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
    ];
  };

  # Optimisations gaming
  programs.gamemode.enable = true;
}
