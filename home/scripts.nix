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

  home.file.".local/bin/power-menu" = {
    executable = true;
    text = ''
      #!/bin/sh
      choice=$(echo -e "Shutdown\nReboot\nSuspend\nLock\nLogout" | wofi --dmenu --prompt "Power")
      case "$choice" in
        Shutdown) systemctl poweroff ;;
        Reboot)   systemctl reboot ;;
        Suspend)  systemctl suspend ;;
        Lock)     hyprlock ;;
        Logout)   hyprctl dispatch exit ;;
      esac
    '';
  };
}
