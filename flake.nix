{
  description = "A simple CLI for Anthropic's API";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python311;
        f = ps: with ps;[
          click
          anthropic
        ];
        pip_python_packages = python.withPackages(f);

        myDevTools = [
          pip_python_packages
        ];
        outputName = builtins.attrNames self.outputs self.outputs;

        claude=with pkgs; stdenv.mkDerivation {
          name = "claude-cli";

          version = "0.0.1";
          propagatedBuildInputs = myDevTools;
          dontUnpack = true;
 
         installPhase = "install -Dm755 ${./claude.py} $out/bin/claude";
        };
      in rec {
        devShells.default = pkgs.mkShell {
          buildInputs = myDevTools;
        };
        packages.default = claude;
        apps.default = flake-utils.lib.mkApp {drv = claude;};
      });
}
