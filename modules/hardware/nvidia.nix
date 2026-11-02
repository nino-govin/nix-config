{
  config,
  lib,
  pkgs,
  ...
}:

{
  _module.args.nvidiaOffloadEnv = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  boot.kernelParams = [ "nvidia_drm.hdmi21_enable=1" ];

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

  environment.etc."modprobe.d/zz-nvidia-fbdev-off.conf".text = ''
    options nvidia-drm fbdev=0
  '';

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
