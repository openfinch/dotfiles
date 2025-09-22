{ config, pkgs, lib, inputs, ... }:
{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Users
  users.users.jf = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJghgtTWcK2pppUJT3fI/vIbfzTAdX6JU0JptGW/K69Y me@joshfinch.com"
    ];
  };
  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;
  
  # Imports
  imports = lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix
    ++ [ inputs.home-manager.nixosModules.home-manager "./persistence.nix" ];

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jf = {
      extraSpecialArgs = { inherit inputs; };
      imports = [ ../../home/common.nix ];
    };
  };

  # Networking
  networking.hostName = lib.mkDefault "balthazar";
  networking.wireless.enable = true;

  # Input
  services.libinput.enable = true;
  console.keyMap = "us";
  services.xserver = {
    xkb.layout = "us,ru";
    xkbVariant = "workman,";
    xkbOptions = "grp:win_space_toggle";
  };
}
