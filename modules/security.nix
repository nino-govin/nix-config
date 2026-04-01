{ config, pkgs, ... }:

{
  security = {
    sudo.enable = true;
    pam.services.hyprlock = {};
  };
}
