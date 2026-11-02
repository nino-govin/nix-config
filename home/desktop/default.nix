{
  imports = [
    ./hyprland.nix
    ./quickshell.nix
    ./hypridle.nix
    ./power.nix
    ./scripts.nix
  ];

  services.hyprpolkitagent.enable = true;
}
