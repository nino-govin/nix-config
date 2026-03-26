{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "nino.govin";
        email = "nino.govin@epita.fr";
      };
      core.editor      = "nvim";
      init.defaultBranch = "main";
      pull.rebase      = false;
    };
  };
}
