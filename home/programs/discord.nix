{ pkgs, lib, ... }: {
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "discord" ];

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
