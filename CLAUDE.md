# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## System Overview

This is a NixOS configuration for a laptop (`nino-nixos`) using flakes and home-manager. The system runs Hyprland (Wayland compositor) with a tuigreet login manager on a laptop with both Intel integrated graphics and NVIDIA discrete GPU using PRIME offload.

## Build and Deployment

**Rebuild the system:**
```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

**Update flake inputs:**
```bash
nix flake update
```

**Garbage collect old generations:**
```bash
nix-collect-garbage -d
```

## Architecture

### Flake Structure
- `flake.nix`: Entry point, defines nixpkgs (25.11) and home-manager inputs
- `configuration.nix`: Main system configuration, imports all module files
- Hostname: `nixos`
- User: `nino-nixos`

### Module Organization

**System modules** (`/etc/nixos/modules/`):
- `boot.nix`: systemd-boot with 0 timeout, 3 generation limit
- `nvidia.nix`: NVIDIA PRIME offload config (Intel primary, NVIDIA on-demand)
  - Key: `nvidia_uvm` is blacklisted at boot
  - Uses open drivers with finegrained power management
  - Bus IDs: Intel `PCI:0:2:0`, NVIDIA `PCI:1:0:0`
- `display.nix`: Hyprland + tuigreet + XDG portals
- `packages/default.nix`: Aggregates system/desktop/dev/media/apps packages
- Other modules: audio, networking, locale, security, virtualisation, fonts, gaming, ai, users

**Home-manager config** (`/etc/nixos/home/`):
- `default.nix`: Main entry point for home-manager
- `hyprland.nix`: Hyprland window manager settings
  - Monitor: eDP-1 at 2560x1600@240Hz, scale 1.6
  - Keyboard layouts: fr,us (toggle with Super+Space)
  - Key bindings use French AZERTY layout (ampersand=1, eacute=2, etc.)
- `adaptive-refresh-rate.nix`: Systemd user service/timer that adjusts display refresh rate based on power state
  - Timer runs 30s after boot, then every 10s
  - Script located at `~/.local/bin/adaptive-refresh-rate`
- Component configs: waybar, wofi, kitty, zsh, starship, dunst, git, hypridle, hyprlock, media
- Custom scripts in `scripts/` directory

### Key Integration Points

**NVIDIA PRIME offload:**
- Command available: `nvidia-offload <command>`
- Desktop entry created for Steam: `steam-nvidia.desktop`
- Main workflow: use integrated Intel graphics by default, offload to NVIDIA on demand

**Display configuration:**
- Primary display scaled to 1.6x for HiDPI
- Firefox also configured with 1.6 device pixel ratio
- Environment variables set for Wayland apps (NIXOS_OZONE_WL, QT_QPA_PLATFORM, etc.)

**Custom home utilities:**
- Power menu: `~/.local/bin/power-menu` (shutdown/reboot/suspend/lock/logout via wofi)
- Adaptive refresh rate script managed by systemd user timer

## Important Configuration Details

- Unfree packages are allowed (`nixpkgs.config.allowUnfree = true`)
- Experimental features enabled: nix-command, flakes
- Auto-optimise store enabled
- Weekly garbage collection (deletes >7d old generations)
- State version: 25.11
- SSH keychain configured for `id_ed25519_github2`
