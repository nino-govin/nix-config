{ config, pkgs, ... }:

{
  imports = [
    ./hyprland.nix
    ./hyprlock.nix
    ./waybar.nix
    ./wofi.nix
    ./kitty.nix
    ./zsh.nix
    ./starship.nix
    ./dunst.nix
    ./git.nix
    ./hypridle.nix
  ];

  home = {
    username      = "nino-nixos";
    homeDirectory = "/home/nino-nixos";
    stateVersion  = "25.11";
  };

  # Laisser Home Manager gérer lui-même
  programs.home-manager.enable = true;

  # Thème GTK global
  gtk = {
    enable = true;
    theme = {
      name    = "Arc-Dark";
      package = pkgs.arc-theme;
    };
    iconTheme = {
      name    = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # Variables d'environnement utilisateur
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.packages = with pkgs; [
    polkit_gnome
  ];

  home.file.".local/bin/power-menu" = {
    executable = true;
    text = ''
      #!/bin/sh
      choice=$(echo -e "Shutdown\nReboot\nSuspend\nLock\nLogout" | wofi --dmenu --prompt "Power")
      case "$choice" in
        Shutdown) systemctl poweroff ;;
        Reboot)   systemctl reboot ;;
        Suspend)  systemctl suspend ;;
        Lock)     hyprlock ;;
        Logout)   hyprctl dispatch exit ;;
      esac
    '';
  };
}
