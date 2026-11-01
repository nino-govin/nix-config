{ lib, pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "screenshot";
      runtimeInputs = with pkgs; [ grim slurp wl-clipboard libnotify ];
      text = ''
        dir="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
        file="$dir/$(date +%Y%m%d_%H%M%S).png"
        mkdir -p "$dir"
        case "''${1:-screen}" in
          area) geometry=$(slurp) || exit 0; grim -g "$geometry" "$file" ;;
          *) grim "$file" ;;
        esac
        wl-copy --type image/png < "$file"
        notify-send -a Screenshot -i "$file" "Screenshot" "Copied to clipboard · $(basename "$file")"
      '';
    })
  ];

  home.activation.vsCodeIcon = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.local/share/icons"
    ${pkgs.imagemagick}/bin/convert \
      /run/current-system/sw/share/icons/hicolor/1024x1024/apps/vscode.png \
      -resize 128x128 \
      "$HOME/.local/share/icons/vscode-128.png"
  '';

  home.file.".local/bin/set-power-profile" = {
    source = ./scripts/set-power-profile.sh;
    executable = true;
  };

  home.file.".local/share/applications/steam-nvidia.desktop" = {
    text = ''
      [Desktop Entry]
      Name=Steam (NVIDIA)
      Comment=Steam sur GPU NVIDIA via PRIME offload
      Exec=nvidia-offload steam %U
      Icon=steam
      Terminal=false
      Type=Application
      Categories=Network;FileTransfer;Game;
    '';
  };
}
