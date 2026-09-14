{ config, pkgs, ... }:

{

  boot.kernelParams = [ "nvidia_drm.hdmi21_enable=1" ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 3;
    };
    timeout = 0;
  };
}
