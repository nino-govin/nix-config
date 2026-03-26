{ config, pkgs, ... }:

{
  # Le CLI docker est automatiquement disponible via cette option
  virtualisation.docker.enable = true;
}
