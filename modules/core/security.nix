{ pkgs, ... }:

{
  security.pam.services.quickshell = { };

  environment.systemPackages = [ pkgs.gnome-keyring ];
}
