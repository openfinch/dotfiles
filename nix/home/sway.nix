{ config, pkgs, lib, ... }:
{
  # Core tools for Wayland/Sway
  home.packages = with pkgs; [
    wl-clipboard
    grim
    slurp
    brightnessctl
    networkmanagerapplet
    blueman
    alacritty
  ];

  programs.wofi.enable = true;
  programs.waybar.enable = true;

  # Sway via Home Manager
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.sway; # Use system sway
    xwayland = true;

    config = {
      modifier = "Mod4"; # Super key
      terminal = "alacritty";
      menu = "wofi --show drun";

      input = {
        "type:keyboard" = {
          xkb_layout = "gb";
          xkb_options = "caps:escape";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };

      keybindings = lib.mkOptionDefault {
        "${config.wayland.windowManager.sway.config.modifier}+Return" = "exec alacritty";
        "${config.wayland.windowManager.sway.config.modifier}+d" = "exec wofi --show drun";
        "${config.wayland.windowManager.sway.config.modifier}+Shift+e" = "exec swaymsg exit";
        "${config.wayland.windowManager.sway.config.modifier}+l" = "exec swaylock -f -c 000000";
        "Print" = "exec grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +%F_%T).png";
      };

      startup = [
        { command = "waybar"; }
        { command = "nm-applet --indicator"; }
        { command = "blueman-applet"; }
      ];
    };
  };

  # Idle + lock
  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 300; command = "swaylock -f -c 000000"; }
      { timeout = 600; command = "swaymsg 'output * dpms off'"; resumeCommand = "swaymsg 'output * dpms on'"; }
    ];
  };

  programs.swaylock.enable = true;

  # Wayland-friendly env
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };
}
