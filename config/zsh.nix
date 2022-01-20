{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nix-zsh-completions
    zsh-completions
    any-nix-shell
  ];
  environment.pathsToLink = [ "/share/zsh" ];
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [
    zsh
  ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions = {
      enable = true;
    };
    syntaxHighlighting = {
      enable = true;
    };
    promptInit = ''
      any-nix-shell zsh --info-right | source /dev/stdin
    '';
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "direnv" ];
      theme = "half-life";
    };
  };
}
