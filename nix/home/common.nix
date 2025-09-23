{ config, pkgs, lib, inputs, ... }:
{
  home.stateVersion = "25.05";

  imports = [
    inputs.impermanence.homeManagerModules.impermanence
    ./persistence.nix
    ./sway.nix
    ./firefox.nix
    ./discord.nix
  ];

  programs.home-manager.enable = true;

  # Common packages for all users on all OSes via HM
  home.packages = with pkgs; [
    git
    vim
    htop
    ripgrep
    fd
    lsof
    inotify-tools
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
