{ config, lib, pkgs, ... }: {
  home.packages = [
    pkgs.discord
  ];

  home.persistence."/nix/persist/home/jf" = {
    allowOther = false;
    directories = [ 
      ".config/discord"
    ];
    files = [ ];
  };
}
