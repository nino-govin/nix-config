{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    claude-code
    nixfmt
    gh
    python3
    black
    pylint
    mypy
    libpq
    uv
    (lib.hiPrio gcc)
    clang
    clang-tools
    cmake
    ninja
    bear
    gnumake
    jdk
    maven
    gradle
    nodejs_24
    pnpm
    vscode
    jetbrains.idea
    postman
    kubectl
    kubernetes-helm
    go
  ];
}
