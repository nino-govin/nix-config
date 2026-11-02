# nino-nixos

Personal NixOS configuration, built with flakes and home-manager. Hyprland (Wayland) desktop configured in Lua, a Quickshell desktop shell and greeter, and NVIDIA PRIME offload on a hybrid Intel/NVIDIA laptop.

## Hardware

- **Laptop:** MSI Pulse 16 AI C1VGKG
- **CPU:** Intel Core Ultra 7 155H
- **GPU:** Intel iGPU (primary) + NVIDIA GeForce RTX 4070 Laptop GPU (PRIME offload)
- **RAM:** 32 GB DDR5
- **Display:** internal `eDP-1`, 2560x1600 @ 240 Hz, scale 1.6

## Usage

```bash
rebuild                      # sudo nixos-rebuild switch --flake /etc/nixos#nixos
update                       # nix flake update + rebuild
cleanup                      # sudo nix-collect-garbage -d
nix fmt                      # format every .nix file (nixfmt-tree)
nixos-rebuild build --flake .#nixos   # build without switching, result in ./result
```

If the Quickshell greeter breaks, pick the `tuigreet` specialisation in the boot menu (hold <kbd>Space</kbd> during boot, the timeout is 0).

## Structure

```
.
├── flake.nix                     # inputs, nixosSystem, home-manager wiring, formatter
├── hosts/nixos/
│   ├── default.nix               # hostname, stateVersion, imports modules/
│   ├── vars.nix                  # shared values: user name, monitor spec, monitorLua helper
│   └── hardware-configuration.nix
├── modules/                      # NixOS (system) modules
│   ├── core/                     # boot, nix settings + overlays, locale, networking, users, security
│   ├── hardware/                 # nvidia, power (auto-cpufreq, power profiles), audio, bluetooth
│   ├── desktop/                  # Hyprland + portals, greetd/Quickshell greeter, fonts, desktop CLI tools
│   ├── services/                 # ollama + AI tools, gaming, docker, nix-ld
│   └── packages.nix              # base CLI tools available to every user (and root)
└── home/                         # home-manager modules
    ├── default.nix               # user identity, session variables
    ├── desktop/                  # Hyprland (+ hyprland.lua), Quickshell service, hypridle, power scripts, screenshot
    ├── shell/                    # zsh, starship, kitty, direnv, git, ssh/keychain
    ├── theming.nix               # GTK, Qt (qtct), cursor
    ├── apps.nix                  # GUI apps, Firefox, Steam (NVIDIA) desktop entry
    ├── dev.nix                   # toolchains, IDEs, CLI dev tools
    └── quickshell/               # Quickshell QML sources (shell + greeter), not a Nix module
```

### Where to put things

| What                                                  | Where                                                                        |
| ----------------------------------------------------- | ---------------------------------------------------------------------------- |
| Value shared by system and home (user, monitor)       | `hosts/nixos/vars.nix`, received as the `host` module argument               |
| Tool needed by root, system services or the greeter   | `modules/packages.nix` or the relevant system module                         |
| Tool called by Hyprland binds, Quickshell or hypridle | `modules/desktop/default.nix`                                                |
| Personal app or dev tool                              | `home/apps.nix` or `home/dev.nix`                                            |
| Environment variables for NVIDIA offload              | `nvidiaOffloadEnv` module argument, defined in `modules/hardware/nvidia.nix` |

## How it works

### NVIDIA

- PRIME offload: the Intel iGPU drives the display, the dGPU is only used through `nvidia-offload <cmd>` (or the `nvidiaOffloadEnv` variables). Fine-grained power management lets the dGPU power off when idle.
- The NVIDIA kernel modules are removed from `modules-load.d` and loaded asynchronously by a udev rule (`modprobe nvidia_drm` when the PCI device appears), so loading them no longer blocks `sysinit.target`.
- `nvidia-drm fbdev=0` is set in `modprobe.d/zz-…` so it overrides the NixOS default.
- Steam has an extra "Steam (NVIDIA)" launcher; osu! stable is wrapped with the offload variables directly.

### Boot

The NVMe drive sits behind Intel VMD (locked on in the BIOS), which drops one interrupt at boot. With the default 30 s NVMe I/O timeout the initrd stalled; `nvme_core.io_timeout=2` (in `modules/hardware/power.nix`) brings this down to a couple of seconds.

### Power profiles

Three profiles, selected from the Quickshell power widget:

| Profile     | CPU                                                            | Wi-Fi power save | Refresh rate                   | Animations / blur |
| ----------- | -------------------------------------------------------------- | ---------------- | ------------------------------ | ----------------- |
| performance | auto-cpufreq, turbo on                                         | off              | always 240 Hz                  | on                |
| balanced    | auto-cpufreq, turbo on                                         | on               | 240 Hz on AC, 60 Hz on battery | on                |
| economy     | auto-cpufreq stopped, turbo off, 800 MHz cap, dGPU autosuspend | on               | always 60 Hz                   | off               |

Flow: Quickshell (`PowerProfileService.qml`) runs `~/.local/bin/set-power-profile <mode>`, which

1. runs the root part, `power-profile-apply` (allowed without password through a sudo rule),
2. stores the mode in `~/.local/share/power-profile`,
3. applies the refresh rate and visual effects through `hyprctl eval`.

The `adaptive-refresh-rate` user timer runs every 10 s and switches between 240 Hz and 60 Hz depending on the charger, but only in the `balanced` profile and never while osu!/wine is running.

auto-cpufreq also limits battery charge to 20–80 %.

### Desktop

- Hyprland reads `~/.config/hypr/hyprland.lua`, generated by home-manager: monitor and cursor lines from Nix, then `require("config")` loads `home/desktop/hyprland.lua`.
- `hyprctl dispatch` takes Lua (`hl.dsp.*`), not the legacy dispatcher syntax.
- Quickshell runs as a systemd user service. `~/.config/quickshell` is an out-of-store symlink to `home/quickshell/`, so QML edits apply without a rebuild. Runtime files written by Quickshell (`settings.json`, generated GTK/Qt/terminal colors, wallpaper selection) are gitignored.
- Quickshell IPC drives the launcher, clipboard, wallpaper picker, power menu, lock screen and media/brightness keys: `qs ipc call <target> <function>`.
- hypridle: screen off after 2 min, lock after 3 min (Quickshell lock screen), suspend after 10 min.

### Greeter

greetd starts a minimal Hyprland (`modules/desktop/greeter.nix`) that runs `home/quickshell/greeter.qml`. Its state (avatar, last session) lives in `/var/lib/jaqc-greeter`. The greeter reads the QML straight from `/etc/nixos`, so the repo must stay at that path.

## Reusing this config

This configuration targets one specific laptop. Before reusing it, adapt `hosts/nixos/vars.nix` (user, monitor), `hosts/nixos/hardware-configuration.nix`, the PRIME bus IDs in `modules/hardware/nvidia.nix`, the dGPU PCI path in `modules/hardware/power.nix`, and the AZERTY bindings in `home/desktop/hyprland.lua`.
