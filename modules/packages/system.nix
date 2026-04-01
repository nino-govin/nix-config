{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git wget curl vim neovim zsh
    kitty
    fastfetch htop btop powertop ncdu duf bat bc
    file lsof ripgrep fuse
    p7zip unzip zip
    tree
    yazi
  ];
}
