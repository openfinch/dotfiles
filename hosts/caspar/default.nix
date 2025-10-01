{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # ./hardware-configuration.nix
    ../common
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "caspar";
  networking.networkmanager.enable = true;

  system.stateVersion = "25.05";
}