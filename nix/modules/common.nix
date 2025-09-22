{ config, pkgs, lib, ... }:
{
  imports = [
    ./wireless-networks.nix
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # Baseline packages & shell tools used across hosts
  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    wget
    curl
    gnumake
    tree
    jq
    ripgrep
    fd
  ];

  # Users are host-specific; keep minimal here
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

  # Allow upgrading without manual interaction
  system.stateVersion = lib.mkDefault "25.05";
}
