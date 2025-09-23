{ config, lib, pkgs, ... }:

let
  inherit (lib) mkDefault getName;
in
{
  # Allow only Discord as unfree by default; override in your config if undesired.
  nixpkgs.config.allowUnfreePredicate = mkDefault (pkg: builtins.elem (getName pkg) [ "discord" ]);

  # Install Discord.
  home.packages = [
    pkgs.discord
  ];
}
