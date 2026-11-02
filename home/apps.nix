{ pkgs, ... }:

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
  home.packages = with pkgs; [
    obsidian
    xdg-utils
    discord-wayland
    google-chrome
    moonlight-qt
    protonup-qt
    obs-studio
    mpv
    pavucontrol
    ffmpeg-full
    scrcpy
    android-tools
  ];

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
    profiles.default.settings."layout.css.devPixelsPerPx" = "1.6";
  };

  xdg.desktopEntries.steam-nvidia = {
    name = "Steam (NVIDIA)";
    comment = "Steam sur GPU NVIDIA via PRIME offload";
    exec = "nvidia-offload steam %U";
    icon = "steam";
    categories = [
      "Network"
      "FileTransfer"
      "Game"
    ];
  };
}
