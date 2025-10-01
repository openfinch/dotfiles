{ config, pkgs, lib, ... }:
let
    cfg = config.networking.wireless;
in
{
    config = lib.mkIf cfg.enable {

    };
}