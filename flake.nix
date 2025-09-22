{
  description = "Dip.sh dotfiles: multi-host Nix flake for NixOS and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    flake-utils.url = "github:numtide/flake-utils";

    impermanence.url = "github:nix-community/impermanence";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, flake-utils, impermanence, firefox-addons }:
    let
      inherit (nixpkgs.lib) nixosSystem;

      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          # Expose an "unstable" package set alongside stable
          (final: prev: {
            unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          })
          (import ./nix/pkgs/overlay.nix)
        ];
      };

  mkNixosHost = { hostname, system ? "x86_64-linux", modules ? [ ] }:
        nixosSystem {
          inherit system;
          pkgs = mkPkgs system;
          specialArgs = {
            inherit nixos-hardware;
            inputs = { inherit nixpkgs nixpkgs-unstable home-manager nixos-hardware impermanence firefox-addons; };
          };
          modules = [
            # Lightweight hostname module
            ({ ... }: { networking.hostName = hostname; })
            # Common settings for all NixOS machines
            ./nix/modules/common.nix
            # Impermanence NixOS module available to all hosts
            impermanence.nixosModules.impermanence
            # Host-specific module dir (expects default.nix)
            (./nix/hosts + "/${hostname}")
          ] ++ modules;
        };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = mkPkgs system;
      in {
        # Dev shell with common tools
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ alejandra nixpkgs-fmt git home-manager deploy-rs ];
        };
        formatter = pkgs.alejandra;
      }
    ) // {
      # NixOS hosts
      nixosConfigurations = {
        balthazar = mkNixosHost {
          hostname = "balthazar";
          system = "x86_64-linux";
          modules = [
            nixos-hardware.nixosModules.lenovo-thinkpad-t490
          ];
        };
      };

      # Home Manager standalone for non-NixOS hosts
      homeConfigurations = {
        # Example: Fedora workstation for user jf
        "jf@fedora" = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs "x86_64-linux";
          modules = [
            ./nix/home/common.nix
            { home.username = "jf"; home.homeDirectory = "/home/jf"; }
          ];
          extraSpecialArgs = { inputs = { inherit nixpkgs nixpkgs-unstable home-manager impermanence firefox-addons; }; };
        };
      };
    };
}
