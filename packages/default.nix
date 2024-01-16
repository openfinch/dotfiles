{ pkgs, inputs }:
rec {
  scripts = pkgs.callPackage ./scripts { };
}
