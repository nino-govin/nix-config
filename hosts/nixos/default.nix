{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  networking.hostName = "nixos";

  system.stateVersion = "25.11";
}
