{ config, lib, pkgs, inputs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "balthazar";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  services.displayManager.ly.enable = true;
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    windowManager.qtile.enable = true;
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/nixos"
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };
  systemd.tmpfiles.rules = [
    "d /nix/persist/secrets 0700 root root -"
    "d /nix/persist/secrets/wifi 0700 root root -"
  ];
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.X11Forwarding = false;
  };
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
  # Improve default journald retention
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxFileSec=7day
  '';
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
}