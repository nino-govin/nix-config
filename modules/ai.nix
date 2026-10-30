{ config, pkgs, lib, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  environment.systemPackages = with pkgs; [
    opencode
    pi-coding-agent
  ];

  environment.variables.PI_SKIP_VERSION_CHECK = "1";

  systemd.services.ollama.environment = {
    OLLAMA_HOST = lib.mkForce "0.0.0.0:11434";
    DRI_PRIME = "1";
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
  };
}
