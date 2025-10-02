{ config, pkgs, lib, inputs, ... }: {
  imports = [
    ./gnome-keyring.nix
    ./firefox.nix
    ./slack.nix
    ./discord.nix
    ./codium.nix
    ./git.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    gnupg
  ];
}