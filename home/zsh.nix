{ config, pkgs, ... }:

{
  programs.zsh = {
    enable       = true;
    autosuggestion.enable  = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreDups   = true;
      ignoreSpace  = true;
      share        = true;
    };

    shellAliases = {
      ll   = "ls -lah";
      la   = "ls -A";
      l    = "ls -CF";
      grep = "grep --color=auto";
      df   = "duf";
      du   = "ncdu";
      cat  = "bat";
      top  = "btop";
      ff   = "fastfetch";

      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      update  = "sudo nix-channel --update && sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      cleanup = "sudo nix-collect-garbage -d && sudo nix-store --gc";
      trim    = "sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system +3 && sudo nix-store --gc";
      nixedit = "sudo nvim /etc/nixos/configuration.nix";
      nixconf = "cd /etc/nixos";

      gs  = "git status";
      ga  = "git add";
      gc  = "git commit";
      gp  = "git push";
      gl  = "git log --oneline --graph";

      phone = "SDL_VIDEODRIVER=x11 DISPLAY=:0 scrcpy --render-driver=opengl";
    };

    initContent = ''
      # fzf keybinds
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      # Initialiser starship
      eval "$(starship init zsh)"
    '';
  };
}
