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
    xwallpaper
  ];

  xdg.configFile = lib.mapAttrs (_: path: {
    source = path;
    recursive = true;
  }) configs;
}