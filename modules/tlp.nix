{ config, pkgs, ... }:

{
  # Module kernel MSI — expose les contrôles EC (charge, ventilateur, etc.)
  # Requis pour que TLP puisse définir les seuils de charge sur laptop MSI
  boot.kernelModules = [ "msi-ec" ];

  # Désactiver power-profiles-daemon — incompatible avec TLP
  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      # ── Seuils de charge batterie ──────────────────────────────────────────
      # TLP essaie BAT0 puis BAT1 selon le laptop (MSI utilise souvent BAT1)
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0  = 80;
      START_CHARGE_THRESH_BAT1 = 75;
      STOP_CHARGE_THRESH_BAT1  = 80;

      # ── CPU ────────────────────────────────────────────────────────────────
      CPU_SCALING_GOVERNOR_ON_AC  = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC  = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # ── Nvidia PRIME — laisser le driver gérer, ne pas interférer ─────────
      # Le power management Nvidia fin est déjà configuré dans nvidia.nix
      RUNTIME_PM_DRIVER_DENYLIST = "nvidia";
    };
  };
}
