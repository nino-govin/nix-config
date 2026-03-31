{ config, pkgs, ... }:

{
  services.ollama = {
    enable       = true;
    acceleration = "cuda";
  };

  environment.systemPackages = with pkgs; [
    claude-code
  ];

}
