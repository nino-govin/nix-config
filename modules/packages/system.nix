{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git wget curl vim neovim zsh
    firefox kitty
    fastfetch htop btop ncdu duf bat bc
    file lsof ripgrep fuse
    p7zip unzip zip
    tree
    yazi
  ];
}
