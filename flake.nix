{
  description = "Application packaged using poetry2nix";

  inputs = {
    flake-utils = { url = "github:numtide/flake-utils"; };
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; })
          mkPoetryApplication;
      in {
        packages = {
          myapp = mkPoetryApplication { projectDir = self; };
          default = self.packages.${system}.myapp;
        };

        # `nix develop`
        devShells.default =
          pkgs.mkShell { inputsFrom = [ self.packages.${system}.myapp ]; };

        # `nix .#poetry`
        devShells.poetry = pkgs.mkShell { packages = [ pkgs.poetry ]; };
      });
}

