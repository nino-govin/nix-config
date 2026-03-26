{ config, pkgs, ... }:

{
  imports = [
    ./system.nix
    ./desktop.nix
    ./dev.nix
    ./media.nix
    ./apps.nix
  ];
}
