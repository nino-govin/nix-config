{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      format = ''
        [╭─](bold #4c566a)$os$username$hostname$directory$git_branch$git_status$nix_shell
        [╰─](bold #4c566a)$character
      '';

      os = {
        disabled = false;
        style = "bold #88c0d0";
        symbols.NixOS = " ";
      };

      username = {
        show_always = false;
        style_user = "bold #a3be8c";
        style_root = "bold #bf616a";
        format = "[$user]($style)";
      };

      hostname = {
        ssh_only = true;
        format = "[@$hostname](bold #ebcb8b) ";
      };

      directory = {
        style = "bold #81a1c1";
        truncation_length = 4;
        truncate_to_repo = false;
        format = "[ $path]($style)[$read_only]($read_only_style) ";
      };

      git_branch = {
        symbol = " ";
        style = "bold #b48ead";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold #ebcb8b";
        format = "([$all_status$ahead_behind]($style) )";
      };

      nix_shell = {
        symbol = " ";
        style = "bold #88c0d0";
        format = "[$symbol$state( \\($name\\))]($style) ";
      };

      character = {
        success_symbol = "[❯](bold #a3be8c)";
        error_symbol = "[❯](bold #bf616a)";
      };
    };
  };
}
