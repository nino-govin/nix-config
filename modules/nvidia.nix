{ config, pkgs, ... }:

{
  # Drivers Nvidia
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    # Gestion de l'alimentation — éteint le GPU Nvidia quand inutilisé
    powerManagement.enable = true;
    powerManagement.finegrained = true;  # plus agressif : éteint le GPU entre chaque usage

    # Driver open source (kernel module) — recommandé pour Ada Lovelace (RTX 40xx)
    open = true;

    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # PRIME offload : iGPU Intel par défaut, Nvidia à la demande
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;  # fournit la commande `nvidia-offload`
      };
      intelBusId  = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Support OpenGL
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver   # VA-API Intel Arc
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
}
