{ lib, pkgs, ... }:

{
  home.activation.vsCodeIcon = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.local/share/icons"
    ${pkgs.imagemagick}/bin/convert \
      /run/current-system/sw/share/icons/hicolor/1024x1024/apps/vscode.png \
      -resize 128x128 \
      "$HOME/.local/share/icons/vscode-128.png"
  '';

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
