{ config, pkgs, inputs, ... }:

{
  home.username = "jf";
  home.homeDirectory = "/home/jf";

  imports = [
    # Impermanence for home manager
    inputs.impermanence.homeManagerModules.impermanence
    # Stuff that's managed by nix
    ./programs
    # Stuff that's managed by traditional dotfiles
    ./dotfiles
  ];

  home.persistence."/nix/persist/home/jf" = {
    allowOther = false;
    directories = [ ".ssh" ];
    files = [];
  };

  home.stateVersion = "25.05";
}
