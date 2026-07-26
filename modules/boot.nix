{ config, pkgs, ... }:

{

  boot.kernelParams = [ "intel_iommu=off" ];

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
