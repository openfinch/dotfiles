{ config, pkgs, lib, ... }:
{
    networking.wireless.networks = {
        magi = {
            pskRaw = "416a9119a97119132460e97f7b19a33eab6f9c9ad73f2ae0ae91eb9603c4fa02";
        };
    };
}