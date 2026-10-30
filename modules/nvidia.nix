{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  environment.etc."modules-load.d/nixos.conf".source = lib.mkForce (
    pkgs.writeText "nixos.conf" (
      lib.concatStringsSep "\n" (
        lib.subtractLists [ "nvidia" "nvidia_modeset" "nvidia_drm" ] config.boot.kernelModules
      )
    )
  );

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", RUN+="${pkgs.kmod}/bin/modprobe nvidia_drm"
  '';

  #boot.blacklistedKernelModules = [ "nvidia_uvm" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      libva-vdpau-driver
      libvdpau-va-gl
      mesa
      vulkan-loader
      vulkan-validation-layers
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.mesa
    ];
  };
}
