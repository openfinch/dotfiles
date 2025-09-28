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
    gtklock
    bemenu
    j4-dmenu-desktop
    mako
    fractal
    gnome-keyring
  ];
  programs.bemenu.enable = true;

  # Sway via Home Manager
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.sway; # Use system sway
    xwayland = true;

    config = {
      modifier = "Mod4"; # Super key
      terminal = "alacritty";
      menu = "j4-dmenu-desktop --dmenu=\"bemenu -i -p 'Run:' -l 20\"";

      assigns = {
        "workspace 1: web" = [{app_id = "firefox";}];
        # "workspace 2: code" = [{app_id = "codium-url-handler";}];
        "workspace 3: chat" = [{class = "slack-wayland";} {class = "discord";}];
      };

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
        "${config.wayland.windowManager.sway.config.modifier}+d" = "exec j4-dmenu-desktop --dmenu=\"bemenu -i -p 'Run:' -l 20\"";
        "${config.wayland.windowManager.sway.config.modifier}+Shift+e" = "exec swaymsg exit";
        "${config.wayland.windowManager.sway.config.modifier}+l" = "exec gtklock -d";
        "Print" = "exec grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +%F_%T).png";
      };

      startup = [
        { command = "nm-applet --indicator"; }
        { command = "blueman-applet"; }
      ];

      window = {
        titlebar = false;
        hideEdgeBorders = "both";
      };
    };
  };

  # Idle + lock
  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 300; command = "gtklock -d"; }
      { timeout = 600; command = "swaymsg 'output * dpms off'"; resumeCommand = "swaymsg 'output * dpms on'"; }
    ];
  };
  # No programs.swaylock: using waylock for a minimal TUI-like lock experience

  # Wayland-friendly env
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    BEMENU_BACKEND = "wayland";
  };
}
