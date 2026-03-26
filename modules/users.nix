{ config, pkgs, ... }:

{
  users.users.nino-nixos = {
    isNormalUser    = true;
    description     = "Nino";
    extraGroups     = [ "docker" "networkmanager" "wheel" "video" "input" ];
    shell           = pkgs.zsh;
    initialPassword = "nixos";  # mot de passe initial — à changer avec passwd après le premier login
  };

  programs.zsh.enable = true;
  # i3lock retiré — remplacé par hyprlock
}
