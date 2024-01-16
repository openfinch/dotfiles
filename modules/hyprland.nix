{ config, pkgs, lib, ... }:
{
  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    xwayland.enable = true;

    # Optional
    # Whether to enable patching wlroots for better Nvidia support
    enableNvidiaPatches = true;
  };
  # programs.sway = {
  #   enable = true;
  #   extraPackages = [ ];
  #   extraSessionCommands = ''
  #     # SDL:
  #     export SDL_VIDEODRIVER=wayland
  #     # Fix for some Java AWT applications (e.g. Android Studio),
  #     # use this if they aren't displayed properly:
  #     export _JAVA_AWT_WM_NONREPARENTING=1
  #     # Clutter:
  #     export CLUTTER_BACKEND=wayland
  #     # Firefox:
  #     export MOZ_ENABLE_WAYLAND=1
  #     # Chromium / Electron (experimental):
  #     export NIXOS_OZONE_WL=1

  #     # Log sway stdout/stderr
  #     exec &> >(${pkgs.systemd}/bin/systemd-cat -t sway)
  #   '';
  #   wrapperFeatures.gtk = true;
  # };

  hardware.opengl.driSupport32Bit = true; #32bit OpenGL

  # greetd display manager
  environment.etc =
    let
      background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
    in
    {
      # gtkgreet list of login environments
      "greetd/environments".text = ''
        sway
        zsh
      '';
    };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time -g \"Access is restricted to authorised personnel only.\" --cmd hyprland";
        user = "greeter";
      };
    };
  };

  users.users.greeter = {
    home = "/run/greeter";
    createHome = true;
  };

  nix.settings.allowed-users = [ "greeter" ];

  home-manager.users.greeter = {
    imports = [
      ../home/nixos.nix
    ];
  };

  environment.systemPackages = with pkgs; [
    gnome.adwaita-icon-theme # gtkgreet
    qt5.qtwayland
  ];

  # XDG Portal
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  # systemd.user.services.xdg-desktop-portal.serviceConfig.ExecStart = lib.mkForce [
  #   # Empty ExecStart value to override the field
  #   ""
  #   "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal -v"
  # ];

  # systemd.user.services.xdg-desktop-portal-wlr.serviceConfig.ExecStart = lib.mkForce [
  #   # Empty ExecStart value to override the field
  #   ""
  #   "${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr -l DEBUG"
  # ];
}