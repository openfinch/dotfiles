{
  imports = [
    ./display-manager.nix
    ./fonts.nix
  ];

  services.xserver.displayManager.sessionCommands = ''
    xwallpaper --zoom ~/.config/walls/wall1.png
  '';
}