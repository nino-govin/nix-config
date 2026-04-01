{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fzf tmux
    # Utiliser : python3 -m venv, ou nix shell, ou un devShell par projet
    python3 black pylint mypy
    gcc valgrind gdb clang clang-tools cmake ninja bear gnumake flex bison
    jdk maven gradle
    nodejs_24 yarn pnpm
    vscode
    jetbrains.idea
  ];
}
