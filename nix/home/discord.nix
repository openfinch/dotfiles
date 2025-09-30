{ config, lib, pkgs, ... }: {
  home.packages = [
    pkgs.discord
  ];

  # Provide an autostart .desktop entry (xdg.autostart.enable is set in common.nix)
  xdg.configFile."autostart/discord.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=Discord
    Comment=Start Discord on login
    Exec=${pkgs.discord}/bin/discord
    Icon=discord
    Terminal=false
    Categories=Network;InstantMessaging;
    X-GNOME-Autostart-enabled=true
  '';

  home.persistence."/nix/persist/home/jf" = {
    allowOther = false;
    directories = [ 
      ".config/discord"
    ];
    files = [ ];
  };
}
