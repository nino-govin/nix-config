{ pkgs, ... }:

{
  home.packages = [
    pkgs.satty
    (pkgs.writeShellApplication {
      name = "screenshot";
      runtimeInputs = with pkgs; [
        grim
        slurp
        wl-clipboard
        libnotify
      ];
      text = ''
        dir="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
        file="$dir/$(date +%Y%m%d_%H%M%S).png"
        mkdir -p "$dir"
        case "''${1:-screen}" in
          area) geometry=$(slurp) || exit 0; grim -g "$geometry" "$file" ;;
          *) grim "$file" ;;
        esac
        wl-copy --type image/png < "$file"
        qs ipc call screenshot open "$file" \
          || notify-send -a Screenshot -i "$file" "Screenshot" "Copied to clipboard · $(basename "$file")"
      '';
    })
  ];
}
