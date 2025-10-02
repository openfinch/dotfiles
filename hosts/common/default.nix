{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Common
    ./packages.nix
    ./gui
    ./persist.nix

    # Services
    ./services/openssh.nix
    ./services/pipewire.nix
    ./services/systemd.nix
    ./services/gnome-keyring.nix
    ./services/nix.nix
  ];

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

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
}