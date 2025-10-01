{ config, pkgs, lib, inputs, ... }:
{
  # Keep boot noise off the greeter VT
  boot.consoleLogLevel = 3; # errors and above
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "udev.log_priority=3"
    "systemd.show_status=false"
    "rd.systemd.show_status=false"
    "console=tty1"
    "vt.global_cursor_default=0"
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Users
  users.users.jf = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = "/nix/persist/secrets/jf-password.hash";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJghgtTWcK2pppUJT3fI/vIbfzTAdX6JU0JptGW/K69Y me@joshfinch.com"
    ];
  };
  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;

  # PAM entries for Wayland lockers so they can authenticate
  security.pam.services.gtklock = {};
  
  # Imports
  imports = lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix
    ++ [
          ./persistence.nix
          ../../modules/greetd.nix
          inputs.home-manager.nixosModules.home-manager
       ];

  # Home Manager
  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users.jf = {
      imports = [ ../../home/common.nix ];
    };
  };

  # Networking
  # Prefer NetworkManager (persists connection profiles under /etc/NetworkManager/system-connections)

  # Input
  services.libinput.enable = true;
  console.keyMap = "uk";
  services.xserver = {
    enable = lib.mkDefault true;
    xkb.layout = "gb";
    xkb.variant = "";
    displayManager.lightdm.enable = lib.mkForce false;
  };

  # Ensure persistent secrets directory exists with strict perms


  # Disable extra VTs so nothing repaints over greetd
  systemd.services."getty@tty1".enable = false;
  systemd.services."getty@tty2".enable = false;
  systemd.services."getty@tty3".enable = false;
  systemd.services."getty@tty4".enable = false;
  systemd.services."getty@tty5".enable = false;
  systemd.services."getty@tty6".enable = false;
}
