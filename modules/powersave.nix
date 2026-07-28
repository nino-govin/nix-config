{ config, pkgs, ... }:

{
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        turbo = "auto";
      };
      battery = {
        governor = "powersave";
        turbo = "auto";
        enable_thresholds = true;
        start_threshold = 20;
        stop_threshold = 80;
      };
    };
  };

  boot.kernelParams = [
    "nmi_watchdog=0"
    "nvme_core.default_ps_max_latency_us=0"
  ];

  boot.kernel.sysctl = {
    "vm.dirty_writeback_centisecs" = 1500;
    "kernel.nmi_watchdog" = 0;
  };

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1
  '';

  networking.networkmanager.wifi.powersave = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"

    ACTION=="add|change", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
  '';

  powerManagement = {
    enable = false;
    powertop.enable = false;
  };
}
