{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fzf
    tmux
    claude-code
    nixfmt
    # Utiliser : python3 -m venv, ou nix shell, ou un devShell par projet
    python3
    black
    pylint
    mypy
    libpq
    uv
    gcc
    valgrind
    gdb
    clang
    clang-tools
    cmake
    ninja
    bear
    gnumake
    flex
    bison
    jdk
    maven
    gradle
    nodejs_24
    yarn
    pnpm
    vscode
    jetbrains.idea
    postman
    kubectl
    kubernetes-helm
    go
  ];

  nixpkgs.config.android_sdk.accept_license = true;
}
