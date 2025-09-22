{ config, lib, pkgs, modulePaths, ... }:

{
    imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
    ];

    # Boot
    boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    boot.initrd.kernelModules = [];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [];

    # Disks
    fileSystems."/" = {
        device = "none";
        fsType = "tmpfs";
        options = [ "defaults" "size=2g" "mode=755" ];
    };
    fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/6A36-C348";
        fsTyoe = "vfat";
        options = [ "fmask=0022" "dmask=0022" ];
    };
    fileSystems."/nix" = {
        device = "/dev/disk/by-uuid/b6d8c457-5550-4b4d-ae07-e38339f89911";
        fsType = "ext4";
    };
    fileSystems."/etc/nixos" = {
        device = "/nix/persist/etc/nixos";
        fsType = "none";
        options = [ "bind" ];
    };
    fileSystems."/var/log" = {
        device = "/nix/persist/var/log";
        fsType = "none";
        options = [ "bind" ];
    };

    swapDevices = [];

    # Networking
    networking.useDHCP = lib.mkDefault true;

    # CPU
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}