{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    shellAliases = {
      ll = "ls -lah";
      la = "ls -A";
      l = "ls -CF";
      grep = "grep --color=auto";
      df = "duf";
      du = "ncdu";
      cat = "bat";
      top = "btop";
      ff = "fastfetch";

      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      update = "nix flake update --flake /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      cleanup = "sudo nix-collect-garbage -d";
      trim = "sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system +3 && sudo nix-store --gc";
      nixconf = "cd /etc/nixos";

      comfy = "(cd ~/ai/ComfyUI && SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt TRITON_LIBCUDA_PATH=/run/opengl-driver/lib nvidia-offload .venv/bin/python main.py --enable-manager)";

      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";

      phone = "SDL_VIDEODRIVER=x11 DISPLAY=:0 scrcpy --render-driver=opengl";
    };
  };

  programs.fzf.enable = true;
}
