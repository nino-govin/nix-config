# Barre du bas : stats techniques
{
  name     = "bottom";
  layer    = "top";
  position = "bottom";
  height   = 36;
  spacing  = 0;

  modules-left   = [
    "custom/cpu-stats"
    "custom/gpu-intel"
    "custom/gpu-nvidia"
  ];
  modules-center = [];
  modules-right  = [
    "network#ip"
    "network#bandwidth"
    "memory"
    "custom/storage"
  ];

  "custom/cpu-stats" = {
    exec        = "~/.local/bin/cpu-stats.sh";
    interval    = 5;
    return-type = "json";
    format      = "CPU 󰻠 {}";
    tooltip     = true;
  };

  "custom/gpu-intel" = {
    exec        = "~/.local/bin/gpu-intel.sh";
    interval    = 5;
    return-type = "json";
    format      = "GPU 󰘚 {}";
    tooltip     = true;
  };

  "custom/gpu-nvidia" = {
    exec        = "~/.local/bin/gpu-nvidia.sh";
    interval    = 5;
    return-type = "json";
    format      = "󰊴 {}";
    tooltip     = true;
  };

  "network#ip" = {
    format-wifi         = "󰖩  {ipaddr}";
    format-ethernet     = "󰈀  {ipaddr}";
    format-disconnected = "󰤭  --";
    tooltip-format-wifi     = "{essid} — {signalStrength}%";
    tooltip-format-ethernet = "{ifname}";
    interval            = 10;
  };

  "network#bandwidth" = {
    format          = "󰕒 {bandwidthUpBits}  󰇚 {bandwidthDownBits}";
    interval        = 2;
    tooltip         = false;
  };

  memory = {
    interval       = 10;
    format         = "󰍛 {used:0.1f}G";
    tooltip-format = "RAM: {used:0.1f}G / {total:0.1f}G";
  };

  "custom/storage" = {
    exec        = "~/.local/bin/storage.sh";
    interval    = 30;
    return-type = "json";
    format      = "󰋊 {}";
    tooltip     = true;
  };
}
