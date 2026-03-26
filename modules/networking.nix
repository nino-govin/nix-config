{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
}
