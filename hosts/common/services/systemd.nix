{
  systemd.tmpfiles.rules = [
    "d /nix/persist/secrets 0700 root root -"
    "d /nix/persist/home/jf 0700 jf users -"
  ];

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxFileSec=7day
  '';
}