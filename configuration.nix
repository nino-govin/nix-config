{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./sddm-theme.nix
    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/locale.nix
    ./modules/display.nix
    ./modules/audio.nix
    ./modules/users.nix
    ./modules/security.nix
    ./modules/virtualisation.nix
    ./modules/fonts.nix
    ./modules/nvidia.nix
    ./modules/tlp.nix
    ./modules/packages/default.nix
  ];

  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 7d";
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store   = true;
  };

  system.stateVersion = "25.11";
}
