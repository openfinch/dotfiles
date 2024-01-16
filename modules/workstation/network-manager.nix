{ config, pkgs, lib, ... }: {
  # NetworkManager
  networking.useDHCP = true;
  networking.networkmanager = {
    enable = true;
  };

  users.users.jf.extraGroups = [
    "networkmanager"
  ];

  modules.tmpfs-as-root.persistentDirs = [
    "/var/lib/NetworkManager"
  ];

  systemd.services.NetworkManager.serviceConfig = {
    StateDirectory = lib.mkForce "";
    ReadWritePaths = [
      "/var/lib/NetworkManager"
      "${config.modules.tmpfs-as-root.storage}/var/lib/NetworkManager"
    ];
  };
}