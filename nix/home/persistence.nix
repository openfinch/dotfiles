{ ... }:
{
  home.persistence."/nix/persist/home/jf" = {
    allowOther = false;
    directories = [ ".ssh" ];
    files = [ ".bash_history" ];
  };
}
