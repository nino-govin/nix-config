{ pkgs, inputs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    gamescope
    desmume
    icu
    (inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.osu-stable.overrideAttrs (oldAttrs: {
      buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.corefonts ];

      wrapperArgs = (oldAttrs.wrapperArgs or [ ]) ++ [
        "--set" "WINE_FORCE_LARGE_FONTS" "1"
        "--set" "WINE_NO_WM_DECORATION" "1"
        "--set" "WINEFSYNC" "1"
        "--set" "__NV_PRIME_RENDER_OFFLOAD" "1"
        "--set" "__NV_PRIME_RENDER_OFFLOAD_PROVIDER" "NVIDIA-G0"
        "--set" "__GLX_VENDOR_LIBRARY_NAME" "nvidia"
        "--set" "__VK_LAYER_NV_optimus" "NVIDIA_only"
        "--set" "__GL_SYNC_TO_VBLANK" "0"
      ];
    }))
    (pkgs.appimage-run.override { extraPkgs = p: [ p.icu ]; })
  ];
}
