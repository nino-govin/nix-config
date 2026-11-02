{ config, host, ... }:

{
  imports = [
    ./desktop
    ./shell
    ./theming.nix
    ./apps.nix
    ./dev.nix
  ];

  home = {
    username = host.user;
    homeDirectory = "/home/${host.user}";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
