{ config, pkgs, lib, inputs, ... }:
{
  # Hardware is added via nixos-hardware module in flake.nix

  networking.hostName = lib.mkDefault "balthazar";

  # Basic bootloader and filesystem placeholders; replace with your actual disk layout later
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Firmware and microcode
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  # Minimal networking
  networking.useDHCP = lib.mkDefault true;

  # Users
  users.users.jf = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      # Add your SSH pubkey here for remote builds/ssh
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  # Desktop placeholder (uncomment if you want GNOME quickly)
  # services.xserver.enable = true;
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Bring in hardware-configuration.nix if present (copy from the machine)
  imports = lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix
    ++ [ inputs.home-manager.nixosModules.home-manager ];

  # Home Manager as a NixOS module (optional): include a host/user profile
  # This expects a module at nix/home/common.nix and per-user overlays later
  # You can remove this if you prefer standalone HM activation
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jf = {
      # Make flake inputs available to HM modules (for impermanence import)
      extraSpecialArgs = { inherit inputs; };
      imports = [ ../../home/common.nix ];
    };
  };
}
