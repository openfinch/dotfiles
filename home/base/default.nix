{ pkgs, ... }: {
  imports = [
    ./zsh.nix
    ../tmpfs-as-home.nix
  ];

  xdg.enable = true;

  tmpfs-as-home.persistentDirs = [
    ".local/share/nix" # nix repl history
    ".cache/nix-index"
  ];

  # automatially trigger X-Restart-Triggers
  systemd.user.startServices = true;
}