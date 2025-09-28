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

  xdg.autostart.entries.slack = {
    name = "Slack";
    exec = "${slackWrapped}/bin/slack-wayland";
    comment = "Start Slack on login";
  };

  programs.zsh.shellAliases.slk = "slack-wayland";
  programs.bash.shellAliases.slk = "slack-wayland";
}
