{ config, pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  systemd.services.ollama.environment = {
    DRI_PRIME = "1";
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
  };
}
