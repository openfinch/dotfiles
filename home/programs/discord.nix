{ pkgs, lib, ... }: {
  home.packages =  with pkgs; [
    discord
  ];

  home.persistence."/nix/persist/home/jf" = {
    allowOther = false;
    directories = [ 
      ".config/discord" # TODO: narrow this down to just session data
    ];
    files = [ ];
  };
}
