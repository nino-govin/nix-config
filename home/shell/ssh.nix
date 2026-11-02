{
  programs.keychain = {
    enable = true;
    keys = [ "id_ed25519_github2" ];
    extraFlags = [
      "--quiet"
      "--nogui"
    ];
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "Host *".AddKeysToAgent = "yes";
      "Host github.com" = {
        IdentityFile = "~/.ssh/id_ed25519_github2";
        IdentitiesOnly = "yes";
      };
    };
  };
}
