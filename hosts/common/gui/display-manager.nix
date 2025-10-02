{
  services.displayManager.ly.enable = true;
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    windowManager.qtile.enable = true;
    displayManager.sessionCommands = ''
      eval $(gnome-keyring-daemon --start --daemonize --components=ssh,secrets)
      export SSH_AUTH_SOCK
    '';
  };
}