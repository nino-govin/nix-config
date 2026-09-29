# CLAUDE.md

## System Overview

NixOS laptop (`nino-nixos`), flakes + home-manager. Hyprland (Wayland) with tuigreet. Intel iGPU primary + NVIDIA dGPU via PRIME offload.

## Build & Deploy

```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
nix flake update
nix-collect-garbage -d
```

## Architecture

**Flake:** nixpkgs 26.05, hostname `nixos`, user `nino-nixos`

**System modules** (`modules/`):
- `boot.nix`: systemd-boot, 0 timeout, 3 gen limit
- `nvidia.nix`: PRIME offload (Intel `PCI:0:2:0`, NVIDIA `PCI:1:0:0`), open drivers, finegrained power mgmt, `nvidia_uvm` blacklisted
- `display.nix`: Hyprland + tuigreet + XDG portals
- `powersave.nix`, `nix-ld.nix`, `ai.nix`, `gaming.nix`
- `packages/`: split into system/desktop/dev/media/apps

**Home modules** (`home/`):
- `hyprland.nix` + `hyprland.lua`: config uses **Lua** (`configType = "lua"`), monitor eDP-1 @ 2560x1600@240Hz scale 1.6, layouts fr,us, AZERTY bindings
- `quickshell.nix`: Quickshell desktop shell, config symlinked from `/etc/nixos/home/quickshell/`, runs as systemd user service after `hyprland-session.target`
- `adaptive-refresh-rate.nix`: systemd user service/timer (30s after boot, every 10s), adjusts refresh rate by power state
- `scripts.nix`: steam-nvidia.desktop (PRIME offload), VSCode icon resize
- `default.nix`: Firefox (DPR 1.6), GTK Arc-Dark + Papirus-Dark, keychain `id_ed25519_github2`, hyprpolkitagent
- Other: wofi, kitty, zsh, starship, dunst, git, hypridle, hyprlock, media

## Key Details

- `nvidia-offload <cmd>` available system-wide
- Startup: `awww-daemon`, `awww img ~/Pictures/background.png`, `nm-applet`, `cliphist`
- Unfree allowed, flakes + nix-command enabled, auto-optimise-store, weekly GC (>7d)
- State version: 25.11

## Hyprland Wiki

Mes connaissances sur Hyprland sont **potentiellement obsolètes**. Avant d'éditer `hyprland.lua` ou toute config Hyprland, consulter la wiki locale :

```
~/Documents/github/hyprland-wiki/
```

Note: la config utilise le format **Lua** (pas le format `.conf` standard).

## Code Style

- No comments in config files
- Keep code concise and self-documenting
