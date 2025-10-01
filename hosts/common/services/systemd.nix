{
  systemd.tmpfiles.rules = [
    "d /nix/persist/secrets 0700 root root -"
  ];

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxFileSec=7day
  '';
}