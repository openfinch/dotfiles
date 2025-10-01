{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, impermanence, nixos-hardware, ... }:
    let
      lib = nixpkgs.lib;

      # Declare your hosts here
      hosts = {
        # Desktop PC
        casper = {
          system = "x86_64-linux";
          modules = [ ./hosts/casper/configuration.nix ];
          user = "jf";};
        # Macbook Pro
        melchior = {
          system = "x86_64-linux";
          modules = [ ./hosts/melchior/configuration.nix ];
          user = "jf";
        };
        # ThinkPad T490
        balthazar = {
          system = "x86_64-linux";
          modules = [
            nixos-hardware.nixosModules.lenovo-thinkpad-t490
            ./hosts/balthazar
          ];
          user = "jf";
        };
      };

      mkHost = name: cfg:
        lib.nixosSystem {
          system = cfg.system;
          modules =
            cfg.modules
            ++ [
              impermanence.nixosModules.impermanence
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${cfg.user} = import ./home/default.nix;
                  backupFileExtension = "bak";
                };
              }
            ];
        };
    in {
      nixosConfigurations = lib.mapAttrs mkHost hosts;
    };
}