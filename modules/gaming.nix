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
    desmume
    icu
    (inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.osu-stable.overrideAttrs (oldAttrs: {
      buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.corefonts ];

      wrapperArgs = (oldAttrs.wrapperArgs or [ ]) ++ [
        "--set"
        "GDK_SCALE"
        "2"
        "--set"
        "WINE_FORCE_LARGE_FONTS"
        "1"
        "--set"
        "WINE_NO_WM_DECORATION"
        "1"
      ];
    }))
    (pkgs.appimage-run.override { extraPkgs = p: [ p.icu ]; })
  ];
}
