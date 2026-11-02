{
  pkgs,
  lib,
  inputs,
  nvidiaOffloadEnv,
  ...
}:

let
  osuEnv = nvidiaOffloadEnv // {
    WINE_FORCE_LARGE_FONTS = "1";
    WINE_NO_WM_DECORATION = "1";
    WINEFSYNC = "1";
    __GL_SYNC_TO_VBLANK = "0";
  };
in

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

      wrapperArgs =
        (oldAttrs.wrapperArgs or [ ])
        ++ lib.concatLists (
          lib.mapAttrsToList (name: value: [
            "--set"
            name
            value
          ]) osuEnv
        );
    }))
    (pkgs.appimage-run.override { extraPkgs = p: [ p.icu ]; })
  ];
}
