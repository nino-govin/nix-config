{ config, pkgs, ... }:

{
  imports = [
    ./hyprland.nix
    ./hyprlock.nix
    ./quickshell.nix
    ./wofi.nix
    ./kitty.nix
    ./zsh.nix
    ./starship.nix
    ./git.nix
    ./hypridle.nix
    ./media.nix
    ./adaptive-refresh-rate.nix
    ./scripts.nix
  ];

  home = {
    username      = "nino-nixos";
    homeDirectory = "/home/nino-nixos";
    stateVersion  = "25.11";
  };

  programs.home-manager.enable = true;

  programs.keychain = {
    enable    = true;
    keys      = [ "id_ed25519_github2" ];
    extraFlags = [ "--quiet" "--nogui" ];
  };

  programs.ssh = {
    enable              = true;
    enableDefaultConfig = false;
    settings."Host *".AddKeysToAgent = "yes";
  };

  programs.firefox = {
    enable      = true;
    configPath  = ".mozilla/firefox";
    profiles.default = {
      settings = {
        "layout.css.devPixelsPerPx" = "1.6";
      };
    };
  };

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
    gtk3.extraConfig = { "gtk-enable-primary-paste" = false; };
    gtk4 = {
      theme = config.gtk.theme;
      extraConfig = { "gtk-enable-primary-paste" = false; };
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  services.hyprpolkitagent.enable = true;
}
