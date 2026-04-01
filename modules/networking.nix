{ config, pkgs, ... }:

{
  networking = {
    hostName     = "nixos";
    nameservers  = [ "1.1.1.1" "1.0.0.1" ];
    networkmanager.enable = true;
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  services.tailscale = {
    enable        = true;
    openFirewall  = true;
    extraUpFlags  = [ "--accept-dns=false" ];
  };
}
