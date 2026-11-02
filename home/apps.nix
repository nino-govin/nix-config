{ pkgs, ... }:

let
  mesaEgl = "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json";
  intelVulkan = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";

  discord-wayland = pkgs.symlinkJoin {
    name = "discord";
    paths = [ pkgs.discord ];
    postBuild = ''
      wrapProgram $out/bin/Discord \
        --set-default CUDA_VISIBLE_DEVICES "" \
        --set-default LIBVA_DRIVER_NAME iHD \
        --set-default VK_DRIVER_FILES ${intelVulkan} \
        --set-default __EGL_VENDOR_LIBRARY_FILENAMES ${mesaEgl} \
        --add-flags "--enable-features=UseOzonePlatform,WaylandLinuxDrmSyncobj --ozone-platform=wayland"
      ln -sf Discord $out/bin/discord
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
    package = pkgs.firefox.overrideAttrs (old: {
      makeWrapperArgs = old.makeWrapperArgs ++ [
        "--set-default"
        "__EGL_VENDOR_LIBRARY_FILENAMES"
        mesaEgl
      ];
    });
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
