{ config, pkgs, lib, ... }:

let
  configs = {
    qtile = ./qtile;
    alacritty = ./alacritty;
    walls = ./walls;
  };
in
{
  home.packages = with pkgs; [
    alacritty
  ];

  xdg.configFile = lib.mapAttrs (_: path: {
    source = path;
    recursive = true;
  }) configs;

  services.xserver.displayManager.sessionCommands = ''
    xwallpaper --zoom ~/nixos-dotfiles/walls/wall1.png
  '';
}