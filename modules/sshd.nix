# Enable the OpenSSH daemon
{ config, lib, ... }:
let
  inherit (lib) mkOption types mkDefault mkIf;

  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMX0USHaVuC7flFuWTTlGi9il5FfnfuHLZSsaBcRaxH Josh Finch"
  ];
in
{
  options.modules.sshd.allowRootLogin = mkOption {
    type = types.bool;
    default = false;
  };

  config = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = if config.modules.sshd.allowRootLogin then "prohibit-password" else "no";
      };
      startWhenNeeded = true;
      ports = mkDefault [ 22 ];
    };

    users.users.jf.openssh.authorizedKeys.keys = keys;
    users.users.root.openssh.authorizedKeys.keys = mkIf (config.modules.sshd.allowRootLogin) keys;

    modules.tmpfs-as-root.persistentFiles = [
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };
}