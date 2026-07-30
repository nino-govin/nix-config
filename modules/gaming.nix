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
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.osu-stable
    (pkgs.appimage-run.override { extraPkgs = p: [ p.icu ]; })
  ];
}
