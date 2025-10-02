{ pkgs, ... }: {
  # Common packages for all users on all OSes via HM
  home.packages = with pkgs; [
    git
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
}
