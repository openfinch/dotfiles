{ pkgs, ... }: {
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  users.users.jf.extraGroups = [
    "docker"
  ];

  modules.tmpfs-as-root.persistentDirs = [
    "/var/lib/docker"
  ];

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}