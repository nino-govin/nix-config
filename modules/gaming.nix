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
    enable      = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      mesa
      vulkan-loader
      vulkan-validation-layers
      intel-media-driver  # VA-API Intel Arc
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.mesa  # Mesa 32-bit pour jeux natifs 32-bit
    ];
  };

  # Optimisations gaming
  programs.gamemode.enable = true;
}
