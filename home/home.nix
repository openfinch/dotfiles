{ config, pkgs, ... }:

{
  home.username = "jf";
  home.homeDirectory = "/home/jf";

  imports = [ ./home.nix ];

  home.stateVersion = "25.05";
}
