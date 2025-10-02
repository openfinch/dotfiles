{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    slack
  ];

  home.persistence."/nix/persist/home/jf" = {
    allowOther = false;
    directories = [ 
      ".config/Slack" # TODO: narrow this down to just session data
    ];
  };
}
