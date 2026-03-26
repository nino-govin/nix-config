{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Outils généraux
    fzf tmux

    # Python
    # Utiliser : python3 -m venv, ou nix shell, ou un devShell par projet
    python3 black pylint mypy

    # C / C++
    gcc valgrind gdb clang clang-tools cmake ninja bear gnumake flex bison

    # Java
    jdk maven gradle

    # JavaScript
    nodejs_24 yarn

    # IDE
    vscode
    jetbrains.idea
  ];
}
