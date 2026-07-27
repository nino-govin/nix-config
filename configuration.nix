{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/locale.nix
    ./modules/display.nix
    ./modules/audio.nix
    ./modules/bluetooth.nix
    ./modules/users.nix
    ./modules/security.nix
    ./modules/virtualisation.nix
    ./modules/fonts.nix
    ./modules/nvidia.nix
    ./modules/ai.nix
    ./modules/gaming.nix
    ./modules/packages/default.nix
    ./modules/powersave.nix
    ./modules/nix-ld.nix
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
