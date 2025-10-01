{
  users.users.jf = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = "/nix/persist/secrets/jf-password.hash";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJghgtTWcK2pppUJT3fI/vIbfzTAdX6JU0JptGW/K69Y me@joshfinch.com"
    ];
  };
  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;
}