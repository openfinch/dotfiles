# Balthazar - Retired Thinkpad T420
{ config, pkgs, ... }:

{
  networking.hostName = "balthazar";

  imports = with inputs.nixos-hardware.nixosModules; [
    ../../modules/base
  ];

  # TODO: Hardware config

  system.stateVersion = "23.11";
}
