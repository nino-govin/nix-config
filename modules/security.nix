{ config, pkgs, ... }:

{
  security = {
    sudo.enable = true;
    pam.services.hyprlock = { };
  };

  environment.systemPackages = with pkgs; [
    gnome-keyring
  ];
}
