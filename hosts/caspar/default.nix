# Caspar - NixOS Workstation
{ config, lib, pkgs, inputs, ... }:

{
  networking.hostName = "caspar";

  imports = with inputs.nixos-hardware.nixosModules; [
    ../../modules/agenix.nix
    ../../modules/base.nix
    ../../modules/grub.nix
    ../../modules/ssd.nix
    ../../modules/sshd.nix
    ../../modules/workstation
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.initrd.luks.devices."cryptroot" = {
    allowDiscards = true;
    bypassWorkqueues = true;
    # WARNING: Remember to update this during setup!!
    device = "/dev/disk/by-uuid/00a3159f-12ca-4600-b730-40427230fe1a";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };
  boot.tmp.useTmpfs = true;


  fileSystems =
    let
      rootDev = "/dev/mapper/cryptroot";
      # only options in first mounted subvolume will take effect so all mounts must have same options
      rootOpts = [ "lazytime" ];
    in
    {
      "/boot" = {
        # WARNING: Remember to update this during setup!!
        device = "/dev/disk/by-uuid/9756-0098";
        fsType = "vfat";
      };
      "/nix" = {
        device = rootDev;
        fsType = "btrfs";
        options = rootOpts ++ [ "subvol=nix" "noatime" ];
      };
      "/var/persist" = {
        device = rootDev;
        fsType = "btrfs";
        neededForBoot = true;
        options = rootOpts ++ [ "subvol=persist" ];
      };
      "/var/swap" = {
        device = rootDev;
        fsType = "btrfs";
        options = rootOpts ++ [ "subvol=swap" "noatime" ];
      };
      "/var/snapshots" = {
        device = rootDev;
        fsType = "btrfs";
        options = rootOpts ++ [ "subvol=snapshots" "noatime" ];
      };
    };

  swapDevices = [
    {
      device = "/var/swap/swapfile";
      discardPolicy = "once";
    }
  ];

  modules.tmpfs-as-root.enable = true;
  modules.tmpfs-as-root.persistentDirs = [];

  modules.btrfs-maintenance = {
    fileSystems = [
      # scrubbling one of subvolumes scrubs the whole filesystem
      "/var/persist"
    ];
  };

  environment.systemPackages = with pkgs; [
    nvme-cli # NVMe SSD
    wireguard-tools
  ];

  # user
  age.secrets.user-password-hash.file = ../../secrets/jf-password-hash.age;
  users.users.jf.hashedPasswordFile = config.age.secrets.user-password-hash.path;

  home-manager.users.jf = {
    imports = [
      # TODO: HomeManager config
      ../../home/nixos.nix
      # ../../home/workstation
      # ../../home/hyprland
    ];
  };

  # hibernation
  boot.resumeDevice = config.fileSystems."/var/swap".device;

  boot.kernelParams = [
    # hibernation - update from `btrfs inspect-internal map-swapfile /var/swap/swapfile`
    "resume_offset=533760"
  ];

  system.stateVersion = "23.11";
}
