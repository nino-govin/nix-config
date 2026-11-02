{
  pkgs,
  lib,
  nvidiaOffloadEnv,
  ...
}:

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

  systemd.services.ollama.environment = nvidiaOffloadEnv // {
    OLLAMA_HOST = lib.mkForce "0.0.0.0:11434";
    DRI_PRIME = "1";
  };
}
