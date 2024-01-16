# Melchior - MacOS Work Laptop
{ config, pkgs, ... }:

{
  networking.hostName = "melchior";

  imports = with inputs.nixos-hardware.nixosModules; [
    ../../modules/base
  ];

  # TODO: Hardware config

  system.stateVersion = "23.11";
}
