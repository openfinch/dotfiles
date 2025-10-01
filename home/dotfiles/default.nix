{ config, pkgs, lib, ... }:

let
  configs = {
    qtile = ./qtile;
    alacritty = ./alacritty;
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
}