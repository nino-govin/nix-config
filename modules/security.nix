{ config, pkgs, ... }:

{
  security = {
    sudo.enable = true;
    pam.services.hyprlock = { };
    pam.services.quickshell = { };
  };

  environment.systemPackages = with pkgs; [
    gnome-keyring
  ];
}
