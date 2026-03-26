{ config, pkgs, ... }:

{
  users.users.nino-nixos = {
    isNormalUser = true;
    description  = "Nino";
    extraGroups  = [ "docker" "networkmanager" "wheel" "video" "input" ];
    shell        = pkgs.zsh;
  };

  programs.zsh.enable = true;
  # i3lock retiré — remplacé par hyprlock
}
