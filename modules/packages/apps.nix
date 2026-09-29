{ config, pkgs, ... }:

let
  discord-wayland = pkgs.symlinkJoin {
    name = "discord";
    paths = [ pkgs.discord ];
    postBuild = ''
      wrapProgram $out/bin/discord \
        --add-flags "--enable-features=UseOzonePlatform,WaylandLinuxDrmSyncobj --ozone-platform=wayland"
    '';
    nativeBuildInputs = [ pkgs.makeWrapper ];
  };
in
{
  environment.systemPackages = with pkgs; [
    obsidian
    xdg-utils
    discord-wayland
    moonlight-qt
    protonup-qt
    google-chrome
    gh
  ];
}
