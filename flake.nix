{
  # A short description for this flake
  description = "A simple CLI for Anthropic's API";

  # The key inputs we will need to build this
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  # This outputs section defines the things we are building.
  # To do its work, it needs to know about this flake and its inputs
  outputs = { self, nixpkgs, flake-utils }:

    # This utility helps us iterate through each of our supported systems
    flake-utils.lib.eachDefaultSystem(system:
      let
        
        # Let's grab Python 3.12 from Nixpkgs 
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python312;

        # Define the Python packages we need here, and look for them
        # within the package group we defined above
        python_packages = python.withPackages( ps: with ps; [
          click
          anthropic
        ]);

        # Grblock m'jabber icbog jerslahmpe. I copied this. No idea.
        outputName = builtins.attrNames self.outputs self.outputs;

        # Use the simplest builder, mkDerivation, to create our output
        # (and call it 'claude'
        claude = with pkgs; stdenv.mkDerivation {

          # These are important and we all know why
          name = "claude-cli";
          version = "0.0.1";

          # Make sure we bring those Python packages we defined above
          propagatedBuildInputs = [ python_packages ];

          # Perhaps this means that our source isn't an archive that needs
          # to be extracted?
          dontUnpack = true;

          # Run this command to install our script into the bin/ dir
          # of our output
          installPhase = "install -Dm755 ${./claude.py} $out/bin/claude";
        };
      in rec {

        # Dev shells need our Python packages too
        devShells.default = pkgs.mkShell {
          buildInputs = [ python_packages ];
        };

        # The main thing inside this flake is the output we called
        # 'claude' and if the flake is run this will be what is run
        packages.default = claude;

        # This comment is proof that I did not write this flake by myself
        # b/c this line means nothing to me
        apps.default = flake-utils.lib.mkApp {drv = claude;};
      }
  );
}
