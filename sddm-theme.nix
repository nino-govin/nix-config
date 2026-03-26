{ config, pkgs, ... }:

let
  monochrome-theme = pkgs.stdenv.mkDerivation {
    pname = "sddm-theme-monochrome";
    version = "2024-05-30";
    src = pkgs.fetchFromGitLab {
      owner = "pwyde";
      repo = "monochrome-kde";
      rev = "20240410";
      sha256 = "sha256-w0Z5H4h+53H8MKR80P5152q3SEp3k5lBhjnbhMrg9uM=";
    };
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -r $src/sddm/themes/monochrome $out/share/sddm/themes/
    '';
  };
in {
  environment.systemPackages = [ monochrome-theme ];

  services.displayManager.sddm.theme = "monochrome";
}
