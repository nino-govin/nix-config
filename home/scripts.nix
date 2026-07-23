{ ... }:

{
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
