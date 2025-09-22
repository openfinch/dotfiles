{ config, pkgs, lib, ... }:
let
    cfg = config.networking.wireless;
in
{
    config = lib.mkIf cfg.enable {
        networking.wireless.extraConfig = ''
            include=/nix/persist/secrets/wifi/*.conf
        '';
    };
}