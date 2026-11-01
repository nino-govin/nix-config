{ config, pkgs, ... }:

{
  imports = [
    ./hyprland.nix
    ./hyprlock.nix
    ./quickshell.nix
    ./kitty.nix
    ./zsh.nix
    ./direnv.nix
    ./starship.nix
    ./git.nix
    ./hypridle.nix
    ./media.nix
    ./adaptive-refresh-rate.nix
    ./scripts.nix
  ];

  home = {
    username = "nino-nixos";
    homeDirectory = "/home/nino-nixos";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  programs.keychain = {
    enable = true;
    keys = [ "id_ed25519_github2" ];
    extraFlags = [
      "--quiet"
      "--nogui"
    ];
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "Host *".AddKeysToAgent = "yes";
      "Host github.com" = {
        IdentityFile = "~/.ssh/id_ed25519_github2";
        IdentitiesOnly = "yes";
      };
    };
  };

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
    profiles.default = {
      settings = {
        "layout.css.devPixelsPerPx" = "1.6";
      };
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      "gtk-enable-primary-paste" = false;
    };
    gtk4 = {
      extraConfig = {
        "gtk-enable-primary-paste" = false;
      };
    };
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    qt5ctSettings.Appearance = {
      custom_palette = true;
      color_scheme_path = "${config.xdg.configHome}/quickshell/qt-colors.conf";
      style = "Fusion";
      icon_theme = "Papirus-Dark";
    };
    qt6ctSettings.Appearance = {
      custom_palette = true;
      color_scheme_path = "${config.xdg.configHome}/quickshell/qt-colors.conf";
      style = "Fusion";
      icon_theme = "Papirus-Dark";
    };
  };

  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  services.hyprpolkitagent.enable = true;
}
