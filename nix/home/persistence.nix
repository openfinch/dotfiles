{ ... }:
{
  # Impermanence HM module is imported from nix/home/common.nix.
  home.persistence."/nix/persist/home/jane" = {
    directories = [ ".ssh" "Downloads" ];
    files = [ ".bash_history" ];
  };
}
