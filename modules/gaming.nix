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
    appimage-run
    icu
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.osu-stable
  ];
}
