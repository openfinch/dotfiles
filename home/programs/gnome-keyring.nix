{
  services.gnome.keyring.enable = true;

  home.persistence."/nix/persist/home/jf" = {
    allowOther = false;
    directories = [ ".local/share/keyrings" ];
    files = [ ];
  };
}