{ pkgs, ... }: {
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "discord" ];

  home.packages =  with pkgs; [
    discord
  ];

  home.persistence."/nix/persist/home/jf" = {
    allowOther = false;
    directories = [ 
      ".config/discord"
    ];
    files = [ ];
  };
}
