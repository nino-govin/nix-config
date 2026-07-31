{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    vim
    neovim
    zsh
    kitty
    fastfetch
    htop
    btop
    powertop
    ncdu
    duf
    bat
    bc
    file
    lsof
    nvme-cli
    ripgrep
    fuse
    jq
    p7zip
    unzip
    zip
    tree
    yazi
  ];
}
