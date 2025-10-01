{ config, lib, pkgs, inputs, ... }:

{
  imports = [ ./user.nix ];
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

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
  ];
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.X11Forwarding = false;
  };

  # Improve default journald retention
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxFileSec=7day
  '';
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  environment.systemPackages = with pkgs; [
    p7zip
    wget
  ];

}