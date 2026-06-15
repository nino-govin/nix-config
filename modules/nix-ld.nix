{ pkgs, ... }:

{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
    SDL2
    libGL
    libGLU
    libpulseaudio
    alsa-lib
    libX11
    libXcursor
    libXrandr
    libXi
    libXext
  ];
}
