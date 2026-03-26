{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # Désactiver l'attente réseau au boot (cause majeure de boot lent)
  systemd.services.NetworkManager-wait-online.enable = false;

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
}
