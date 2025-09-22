{ config, pkgs, lib, inputs, ... }:
{
  home.stateVersion = "25.05";

  imports = [
  "${inputs.impermanence}/home-manager.nix"
    ./persistence.nix
  ];

  programs.home-manager.enable = true;

  # Common packages for all users on all OSes via HM
  home.packages = with pkgs; [
    git
    vim
    htop
    ripgrep
    fd
  ];

  programs.git = {
    enable = true;
    userName = "jf";
    userEmail = "you@example.com"; # TODO: set your real email
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
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
