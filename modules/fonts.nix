{ config, pkgs, ... }:

let
  manrope = pkgs.stdenvNoCC.mkDerivation {
    name = "manrope-variable";
    src = pkgs.fetchurl {
      url = "https://github.com/google/fonts/raw/main/ofl/manrope/Manrope%5Bwght%5D.ttf";
      name = "Manrope-variable.ttf";
      sha256 = "0h0aifzi27fvd6xnrdz2557vvi3ks5xrshbjh5wnxwqabpj9nqyh";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/fonts/truetype
      cp $src $out/share/fonts/truetype/Manrope-variable.ttf
    '';
  };
in

{
  fonts.packages = with pkgs; [
    manrope
    nerd-fonts.symbols-only
    terminus_font
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    defaultFonts = {
      sansSerif = [
        "Manrope"
        "Noto Sans"
        "Noto Sans CJK JP"
      ];
      serif = [
        "Noto Serif"
        "Noto Serif CJK JP"
      ];
      monospace = [
        "Noto Sans Mono"
        "Noto Sans Mono CJK JP"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
