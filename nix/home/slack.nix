{ config, lib, pkgs, ... }:

let
  # Allow only Slack as unfree (avoids broad allowUnfree = true)
  allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "slack" ];

  slackPkg = pkgs.slack;

  # Optional wrapper adding Wayland / ozone flags (use slack-wayland)
  slackWrapped = pkgs.writeShellScriptBin "slack-wayland" ''
    exec ${slackPkg}/bin/slack \
      --ozone-platform-hint=auto \
      --enable-features=WaylandWindowDecorations \
      "$@"
  '';
in {
  nixpkgs.config.allowUnfreePredicate = allowUnfreePredicate;

  home.packages = [
    slackPkg         # original desktop integration
    slackWrapped     # wrapper with Wayland-friendly flags
  ];

  # Provide an autostart .desktop entry (xdg.autostart.enable is set in common.nix)
  xdg.configFile."autostart/slack-wayland.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=Slack (Wayland)
    Comment=Start Slack on login
    Exec=${slackWrapped}/bin/slack-wayland
    Icon=slack
    Terminal=false
    Categories=Network;InstantMessaging;
    X-GNOME-Autostart-enabled=true
  '';

  programs.zsh.shellAliases.slk = "slack-wayland";
  programs.bash.shellAliases.slk = "slack-wayland";

  home.persistence."/nix/persist/home/jf" = {
    allowOther = false;
    directories = [ 
      ".config/Slack"
    ];
  };
}
