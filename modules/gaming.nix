{ pkgs, inputs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      mesa
      vulkan-loader
      vulkan-validation-layers
      intel-media-driver
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.mesa
    ];
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    desmume
    appimage-run icu
    inputs.nix-gaming.packages.${pkgs.system}.osu-stable
  ];
}
