{ self, nixpkgs, nixpkgs-unstable, ... } @ inputs:
{
  packages = final: prev: {
    ngkz = (import ./packages { pkgs = final; inherit inputs; })
      // (import ./packages/lib { pkgs = final; });
  };

  # make nixos-unstable packages accessible through pkgs.unstable.package
  unstable = final: prev: {
    unstable = import nixpkgs-unstable { inherit (prev) system; };
  };
}