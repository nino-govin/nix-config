{ config, pkgs, ... }:

{
  networking = {
    hostName     = "nixos";
    nameservers  = [ "1.1.1.1" "1.0.0.1" ];
    networkmanager.enable = true;
  };

  # Désactiver l'attente réseau au boot (cause majeure de boot lent)
  systemd.services.NetworkManager-wait-online.enable = false;

  services.tailscale = {
    enable        = true;
    openFirewall  = true;
    extraUpFlags  = [ "--accept-dns=false" ];
  };
}
