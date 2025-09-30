{ config, pkgs, lib, inputs, ... }:
{

  # Common packages for all users on all OSes via HM
  home.packages = with pkgs; [
    vscodium
  ];

  # programs.vscodium.
}
