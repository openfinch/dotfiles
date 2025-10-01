{ config, pkgs, ... }:

{
  home.username = "jf";
  home.homeDirectory = "/home/jf";

  imports = [
    # Stuff that's managed by traditional dotfiles
    ./dotfiles
  ];

  home.stateVersion = "25.05";
}
