{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ../common
  ];
  networking.hostName = "melchior";
  system.stateVersion = "25.05";
}