{ config, pkgs, ... }:

{
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 3;
    };
    timeout = 5;
  };

  # Supprimer les messages kernel au boot (évite le TTY visible derrière tuigreet)
  boot.kernelParams    = [ "quiet" "rd.systemd.show_status=false" "rd.udev.log_level=3" ];
  boot.initrd.verbose  = false;
  boot.consoleLogLevel = 0;
}
