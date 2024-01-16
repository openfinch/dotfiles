{ config, osConfig, pkgs, ... }:
{
  tmpfs-as-home.persistentDirs = [
    ".local/share/zsh"
  ];

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    history = {
      extended = true;
      path = "${config.xdg.dataHome}/zsh/history";
      size = 100000;
      save = 100000;
    };
  };
}