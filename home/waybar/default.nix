{ config, pkgs, ... }:

let
  topBar    = import ./top.nix;
  bottomBar = import ./bottom.nix;
in
{
  home.file.".local/bin/cpu-stats.sh"       = { executable = true; source = ../scripts/cpu-stats.sh; };
  home.file.".local/bin/gpu-intel.sh"       = { executable = true; source = ../scripts/gpu-intel.sh; };
  home.file.".local/bin/gpu-nvidia.sh"      = { executable = true; source = ../scripts/gpu-nvidia.sh; };
  home.file.".local/bin/storage.sh"         = { executable = true; source = ../scripts/storage.sh; };
  home.file.".local/bin/keyboard-layout.sh" = { executable = true; source = ../scripts/keyboard-layout.sh; };

  programs.waybar = {
    enable         = true;
    systemd.enable = true;
    style          = builtins.readFile ./style.css;
    settings       = [ topBar bottomBar ];
  };
}
