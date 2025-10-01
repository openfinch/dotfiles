{ config, pkgs, ... }:

{
  home.username = "jf";
  home.homeDirectory = "/home/jf";
  programs.git.enable = true;
  home.stateVersion = "25.05";
  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos, btw";
    };
  };
}
