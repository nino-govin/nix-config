{ config, pkgs, ... }:

{
  imports = [
    ./hyprland.nix
    ./hyprlock.nix
    ./waybar
    ./wofi.nix
    ./kitty.nix
    ./zsh.nix
    ./starship.nix
    ./dunst.nix
    ./git.nix
    ./hypridle.nix
    ./media.nix
    ./adaptive-refresh-rate.nix
  ];

  home = {
    username      = "nino-nixos";
    homeDirectory = "/home/nino-nixos";
    stateVersion  = "25.11";
  };

  # Laisser Home Manager gérer lui-même
  programs.home-manager.enable = true;

  # Agent SSH persistant — keychain partage l'agent entre tous les terminaux
  # et ne demande la passphrase qu'une seule fois par reboot
  programs.keychain = {
    enable    = true;
    keys      = [ "id_ed25519_github2" ];
    extraFlags = [ "--quiet" "--nogui" ];
  };

  programs.ssh = {
    enable                = true;
    enableDefaultConfig   = false;
    matchBlocks."*".addKeysToAgent = "yes";
  };

  # Firefox avec scaling HiDPI forcé
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "layout.css.devPixelsPerPx" = "1.6";
      };
    };
  };

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
    jq
    obsidian
  ];

  home.file.".local/share/applications/steam-nvidia.desktop" = {
    text = ''
      [Desktop Entry]
      Name=Steam (NVIDIA)
      Comment=Steam sur GPU NVIDIA via PRIME offload
      Exec=nvidia-offload steam %U
      Icon=steam
      Terminal=false
      Type=Application
      Categories=Network;FileTransfer;Game;
    '';
  };

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
