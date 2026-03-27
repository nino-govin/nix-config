{ config, pkgs, ... }:

{
  services.ollama = {
    enable       = true;
    acceleration = "cuda";
  };

  services.comfyui = {
    enable = true;
    port   = 8188;
  };
}
