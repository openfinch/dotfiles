{ config, pkgs, lib, ... }:
let
  inherit (lib.ngkz) rot13;
in
{
  imports = [
    ./printing.nix
    ./network-manager.nix
    ./docker.nix
  ];

  # PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Dev manpages
  documentation.dev.enable = true;

  environment.systemPackages = with pkgs; with linuxPackages; [
    # Secureboot / UEFI tooling
    efitools
    sbsigntool

    # Dev manpages
    man-pages
    man-pages-posix
    stdmanpages
    linux-manual
    stdman
  ];

  # install fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
      corefonts
      dejavu_fonts
      freefont_ttf
      gyre-fonts
      liberation_ttf
      unifont
      ngkz.sarasa-term-j-nerd-font
      ngkz.vcr-eas-font
    ];

    # Create a directory with links to all fonts in /run/current-system/sw/share/X11/fonts
    fontDir.enable = true;

    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Noto Sans CJK JP" ];
        serif = [ "Noto Serif CJK JP" ];
        emoji = [ "Blobmoji" ];
        monospace = [ "Sarasa Term J Nerd Font" ];
      };
      cache32Bit = true;
      # XXX Workaround for nixpkgs#46323
      localConf = builtins.readFile "${pkgs.ngkz.blobmoji-fontconfig}/etc/fonts/conf.d/75-blobmoji.conf";
    };
  };

  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;

  programs.ssh = {
    startAgent = true;
    forwardX11 = true;
    knownHosts = {
      "github.com".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
    };
  };

  environment.variables = {
    # Enable Gstreamer hardware decoding
    GST_PLUGIN_FEATURE_RANK = "vampeg2dec:MAX,vah264dec:MAX,vah265dec:MAX,vavp8dec:MAX,vavp9dec:MAX,vaav1dec:MAX";
  };

  fonts.fontconfig.enable = true;

  services.fwupd.enable = true;

  services.btrbk = lib.mkIf (builtins.any (fs: fs.fsType == "btrfs") (builtins.attrValues config.fileSystems)) {
    instances.btrbk = {
      settings = {
        snapshot_preserve_min = "latest";
        snapshot_preserve = "24h 2d";
        subvolume = "/var/persist/home";
        snapshot_dir = "/var/snapshots";
      };
      onCalendar = "hourly";
    };
  };

  xdg.sounds.enable = true;

  # enable all magic sysrq functions
  boot.kernel.sysctl."kernel.sysrq" = 1;

  # qemu-user
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # wireguard
  # XXX https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/997
  networking.firewall = {
    # if packets are still dropped, they will show up in dmesg
    logReversePathDrops = true;
    # wireguard trips rpfilter up
    extraCommands = ''
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 53 -j RETURN
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 53 -j RETURN
    '';
    extraStopCommands = ''
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 53 -j RETURN || true
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 53 -j RETURN || true
    '';
  };
}