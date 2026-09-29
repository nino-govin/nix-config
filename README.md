# nino-nixos

Personal NixOS configuration, built with flakes and home-manager. Hyprland (Wayland) desktop with a Lua-based config, NVIDIA PRIME offload, and a Quickshell-based shell.

## Hardware

- **Laptop:** MSI Pulse 16 AI C1VGKG
- **CPU:** Intel Core Ultra 7 155H
- **GPU:** Intel iGPU (primary) + NVIDIA GeForce RTX 4070 Laptop GPU (PRIME offload)
- **RAM:** 32 Go DDR5 (modified base kit to double capacity)
- **Display:** internal `eDP-1` @ 2560x1600@240Hz (scale 1.6)

## Highlights

- **Flake-based**, nixpkgs 26.05, single host (`nixos`)
- **Hyprland** window manager, configured in **Lua**, AZERTY bindings, fr/us layouts
- **NVIDIA PRIME offload**, Intel iGPU drives the display, NVIDIA dGPU only used on demand via `nvidia-offload <cmd>`
- **Quickshell** as the desktop shell (bars, widgets), config symlinked into the repo
- **tuigreet** greeter + `greetd`, Catppuccin/Nord-ish terminal theming
- Adaptive refresh-rate switching based on power state (AC vs. battery)
- Gaming support (Steam with NVIDIA offload desktop entry, osu-related tweaks)

## Structure

```
.
├── configuration.nix          # top-level system config, imports all modules
├── hardware-configuration.nix # generated hardware config
├── flake.nix / flake.lock
├── modules/                   # system-level NixOS modules
│   ├── boot.nix                # systemd-boot, fast boot, generation limit
│   ├── networking.nix           # hostname, DNS, Tailscale, firewall
│   ├── nvidia.nix                # PRIME offload GPU setup
│   ├── display.nix              # Hyprland + greetd + XDG portals
│   ├── users.nix, security.nix, audio.nix, bluetooth.nix, fonts.nix
│   ├── virtualisation.nix, powersave.nix, nix-ld.nix, ai.nix, gaming.nix
│   └── packages/                # system/desktop/dev/media/apps package sets
└── home/                       # home-manager modules
    ├── default.nix               # Firefox, GTK theme, keychain, polkit agent
    ├── hyprland.nix + hyprland.lua  # Hyprland config (Lua!)
    ├── quickshell.nix + quickshell/ # desktop shell
    ├── adaptive-refresh-rate.nix    # systemd user service/timer
    ├── scripts.nix + scripts/       # misc user scripts
    ├── git.nix, zsh.nix, starship.nix, kitty.nix, hypridle.nix, hyprlock.nix, media.nix
```

## Notes

This configuration is tailored to my specific hardware (MSI Pulse 16 AI, hybrid Intel/NVIDIA graphics, AZERTY setup) — feel free to browse for ideas, but expect to adapt paths, monitor names/resolutions, and bus IDs before reusing it.
