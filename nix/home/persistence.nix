{ pkgs, ... }:
{
    home.persistence."/nix/persist/home/jane" = {
      directories = [ ".ssh" "Downloads" ];
      files = [ ".bash_history" ];
    };
}
