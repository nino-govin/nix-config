{ pkgs, config, ... }:

{
  home.packages = [ pkgs.quickshell ];

  xdg.configFile."quickshell".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nixos/home/quickshell";

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell desktop shell";
      After = [ "hyprland-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell";
      Restart = "on-failure";
      RestartSec = "2s";
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };
}
