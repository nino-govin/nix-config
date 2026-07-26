{ config, pkgs, ... }:

{
  boot.kernelParams = [ "nvme_core.default_ps_max_latency_us=0" ];

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
