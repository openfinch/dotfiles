{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    oh-my-zsh.enable = true;
    oh-my-zsh.theme = "agnoster";
    oh-my-zsh.plugins = [ "git" ];
  };
}