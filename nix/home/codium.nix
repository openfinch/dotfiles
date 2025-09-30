{
  imports = [
    (fetchTarball "https://github.com/unicap/nixos-vscodium-server/tarball/master")
  ];

  services.vscodium-server.enable = true;
}
