{ config, pkgs, ... }:

let
  qtctAppearance = {
    custom_palette = true;
    color_scheme_path = "${config.xdg.configHome}/quickshell/qt-colors.conf";
    style = "Fusion";
    icon_theme = "Papirus-Dark";
  };
in
{
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig."gtk-enable-primary-paste" = false;
    gtk4.extraConfig."gtk-enable-primary-paste" = false;
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
    qt5ctSettings.Appearance = qtctAppearance;
    qt6ctSettings.Appearance = qtctAppearance;
  };
}
