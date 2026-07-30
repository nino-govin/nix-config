{ config, pkgs, ... }:

let
  cpupower = "${pkgs.linuxPackages.cpupower}/bin/cpupower";
  iw       = "${pkgs.iw}/bin/iw";

  powerProfileApply = pkgs.writeShellScriptBin "power-profile-apply" ''
    MODE="$1"
    WIFI_IFACE=$(${iw} dev 2>/dev/null | awk '/Interface/{print $2; exit}')

    _reset_freq_cap() {
      for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
        max=$(cat "$(dirname $cpu)/cpuinfo_max_freq" 2>/dev/null) && echo "$max" > "$cpu" 2>/dev/null || true
      done
    }

    case "$MODE" in
      performance)
        echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo
        _reset_freq_cap
        ${cpupower} frequency-set -g performance 2>/dev/null
        systemctl start auto-cpufreq 2>/dev/null || true
        [ -n "$WIFI_IFACE" ] && ${iw} dev "$WIFI_IFACE" set power_save off
        ;;
      balanced)
        echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo
        _reset_freq_cap
        ${cpupower} frequency-set -g powersave 2>/dev/null
        systemctl start auto-cpufreq 2>/dev/null || true
        [ -n "$WIFI_IFACE" ] && ${iw} dev "$WIFI_IFACE" set power_save on
        ;;
      economy)
        systemctl stop auto-cpufreq 2>/dev/null || true
        echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo
        ${cpupower} frequency-set -g powersave 2>/dev/null
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
          echo 800000 > "$cpu" 2>/dev/null || true
        done
        [ -n "$WIFI_IFACE" ] && ${iw} dev "$WIFI_IFACE" set power_save on
        echo 0 > /sys/bus/pci/devices/0000:01:00.0/power/runtime_autosuspend_delay_ms 2>/dev/null || true
        echo auto > /sys/bus/pci/devices/0000:01:00.0/power/control 2>/dev/null || true
        ;;
      *)
        exit 1
        ;;
    esac
  '';
in

{
  environment.systemPackages = [ powerProfileApply ];

  security.sudo.extraRules = [{
    users = [ "nino-nixos" ];
    commands = [
      { command = "/run/current-system/sw/bin/power-profile-apply"; options = [ "NOPASSWD" ]; }
    ];
  }];

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

  environment.etc."modprobe.d/zz-nvidia-fbdev-off.conf".text = ''
    options nvidia-drm fbdev=0
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
