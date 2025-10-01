{ config, pkgs, lib, inputs, ... }:
{
  home.stateVersion = "25.05";

  imports = [
    inputs.impermanence.homeManagerModules.impermanence
    ./persistence.nix
    ./sway.nix
    ./firefox.nix
    ./discord.nix
    ./slack.nix
    ./codium.nix
  ];

  programs.home-manager.enable = true;
  xdg.autostart.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (_: true);

  # Common packages for all users on all OSes via HM
  home.packages = with pkgs; [
    git
    vim
    htop
    ripgrep
    fd
    lsof
    inotify-tools
    gcr
  ];

  programs.git = {
    enable = true;
    userName = "Josh Finch";
    userEmail = "me@joshfinch.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh.enable = true;
    oh-my-zsh.theme = "agnoster";
    oh-my-zsh.plugins = [ "git" "fzf" ];
  };

  programs.fzf.enable = true;
}
