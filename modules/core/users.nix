{ pkgs, host, ... }:

{
  users.users.${host.user} = {
    isNormalUser = true;
    description = "Nino";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
      "video"
      "input"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
}
