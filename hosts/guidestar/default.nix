# Guidestar - Home Server
{ config, pkgs, ... }:

{
  networking.hostName = "guidestar";

  imports = with inputs.nixos-hardware.nixosModules; [
    ../../modules/base
  ];

  # TODO: Hardware config

  system.stateVersion = "23.11";
}
