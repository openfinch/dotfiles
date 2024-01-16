{ config, lib, pkgs, ... }:
let
  grub = pkgs.grub2.override { efiSupport = true; };
  archSuffix = ({
    x86_64-efi = "x64";
    i386-efi = "ia32";
    arm = "arm";
    aarch64 = "aa64";
  }).${grub.grubTarget};
  boot = "/boot";
  esp = config.boot.loader.efi.efiSysMountPoint;
  efiBootLoaderId = lib.replaceStrings [ "/" ] [ "-" ] esp;
  bootLoaderId = "NixOS${efiBootLoaderId}";
in
{
  # hide grub password hash from unprivileged users
  fileSystems.${boot}.options = [ "fmask=077" ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };
}