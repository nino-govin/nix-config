{ config, pkgs, ... }:

{
  security = {
    sudo.enable = true;
    # i3lock-color retiré — remplacé par hyprlock
    pam.services.hyprlock = {};  # permet à hyprlock de déverrouiller la session
  };
}
