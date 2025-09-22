{ config, pkgs, lib, inputs, ... }:
{
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
  
  # Imports
  imports = lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix
    ++ [
          ./persistence.nix
          ../../modules/greetd.nix
          inputs.home-manager.nixosModules.home-manager
       ];

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    users.jf = {
      imports = [ ../../home/common.nix ];
    };
  };

  # Networking
  networking.hostName = lib.mkDefault "balthazar";
  networking.wireless.enable = true;

  # Input
  services.libinput.enable = true;
  console.keyMap = "uk";
  services.xserver = {
    enable = lib.mkDefault true;
    xkb.layout = "gb";
    xkb.variant = "";
    displayManager.lightdm.enable = lib.mkForce false;
  };

  # Wayland compositor for greetd's tuigreet --cmd sway
  programs.sway.enable = true;

  # Portals for Wayland (screenshare, file dialogs)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  # PipeWire for audio/screen sharing (if not already enabled elsewhere)
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
  };

  # Ensure persistent secrets directory exists with strict perms
  systemd.tmpfiles.rules = [
    "d /nix/persist/secrets 0700 root root -"
  ];
}
