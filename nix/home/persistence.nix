{ ... }:
{
  home.persistence."/nix/persist/home/jf" = {
    allowOther = false;
    directories = [ ".ssh" ".local/share/keyrings" ];
    files = [ ".bash_history" ];
  };
}
