# Configuration applied to all hosts

{ config, lib, pkgs, utils, inputs, ... }:
let
  inherit (lib) mapAttrs filterAttrs mapAttrsToList mkIf;
  inherit (inputs) self home-manager;
in
{
  imports = [
    home-manager.nixosModule
    ./tmpfs-as-root.nix
  ];

  config = {
    nixpkgs = import ../../nixpkgs.nix inputs;

    # Enable experimental flakes feature
    nix =
      let
        filteredInputs = filterAttrs (n: _: n != "self") inputs;
        nixPathInputs = mapAttrsToList (n: v: "${n}=${v}") filteredInputs;
        registryInputs = mapAttrs (_: v: { flake = v; }) filteredInputs;
      in
      {
        # Enable flake
        package = pkgs.nixFlakes;
        extraOptions = ''
          experimental-features = nix-command flakes

          # Keep build-time dependencies when GC
          # keep-outputs = true
          # keep-derivations = true
        '';

        settings = {
          # Only allow administrative users to connect the nix daemon
          allowed-users = [ "root" "@wheel" ];

          trusted-users = [ "root" ];
        };

        # It’s often convenient to pin the nixpkgs flake to the exact version
        # of nixpkgs used to build the system. This ensures that commands
        # like nix shell nixpkgs#<package> work more efficiently since
        # many or all of the dependencies of <package> will already be
        # present.
        registry = registryInputs // { dotfiles.flake = inputs.self; };

        nixPath = nixPathInputs ++ [
          "dotfiles=${inputs.self}"
        ];
      };

    # Let 'nixos-version --json' know the Git revision of this flake.
    system.configurationRevision = mkIf (self ? rev) self.rev;

    # Select internationalisation properties.
    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
    services.xserver = {
      layout = "gb";
      xkbVariant = "";
    };
    console.keyMap = "uk";

    # User accounts
    users = {
      mutableUsers = false;

      users = {
        # disable root login
        root.hashedPassword = "*";

        # define a primary user account
        jf = {
          isNormalUser = true;
          uid = 1000;
          extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
          shell = pkgs.zsh;
        };
      };
    };

    # sudo
    security.sudo = {
      #execWheelOnly = true; # btrbk can't run with this option
      extraConfig = ''
        # rollback results in sudo lectures after each reboot
        Defaults lecture = never
      '';
    };

    # home-manager
    home-manager = {
      useGlobalPkgs = true; # use global nixpkgs
      # install per-user packages to /etc/profiles to make nixos-rebuild build-vm work
      useUserPackages = true;
      users.jf = { osConfig, config, ... }: {
        imports = [
          ../../home/nixos.nix
          ../../home/base
          ../../home/tmpfs-as-home.nix
        ];

        home.tmpfs-as-home = {
          enable = osConfig.modules.tmpfs-as-root.enable;
          storage = osConfig.modules.tmpfs-as-root.storage + config.home.homeDirectory;
        };
      };
      extraSpecialArgs = {
        inherit inputs;
        lib = lib.extend (_: _: home-manager.lib);
      };
    };

    environment.pathsToLink = [ "/share/zsh" ]; #zsh
    environment.systemPackages = with pkgs; [
      btrfs-progs
      jq
      git
      curl
      inetutils
    ];

    services.udev.extraRules = ''
      # set scheduler for NVMe SSD
      ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
      # set scheduler for SATA SSD and eMMC
      ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
      # set scheduler for rotating disks
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
    '';

    # XXX Apply home.sessionPath when logging in via ssh
    programs.zsh.enable = true;

    # XXX Apply home.sessionVariables. Workaround for home-manager #1011
    environment.extraInit = ''
      if [ -e "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
        . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
      fi
    '';

    # use bbr congestion control algorithm
    boot.kernelModules = [ "tcp_bbr" ];
    boot.kernel.sysctl = {
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "cake";
      "net.ipv4.tcp_notsent_lowat" = 16384;
    };

    # record machine-check exception
    hardware.rasdaemon.enable = true;
  };
}
