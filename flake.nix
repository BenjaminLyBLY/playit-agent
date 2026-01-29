{
  description = "playit.gg CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

        # Use the stable Rust toolchain provided by the overlay
        rustToolchain = pkgs.rust-bin.stable.latest.default;

        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustToolchain;
          rustc = rustToolchain;
        };

      in
      {
        packages.default = pkgs.pkgsStatic.rustPlatform.buildRustPackage {
          pname = "playit-agent";
          version = "0.17.1";

          src = pkgs.fetchFromGitHub {
            owner = "playit-cloud";
            repo = "playit-agent";
            rev = "v0.17.1";
            hash = "sha256-kT7NLUcgGM/hxwK4PUDZ71PtYJqjR8i4yj/LhbXX1i0=";
          };

          # This tells Nix exactly which dependencies to download
          cargoHash = "sha256-NcRND1lBbRs8/byiAQx0kGgc5Yw5PxhXxo+9FX9lbv0=";

          meta = with pkgs.lib; {
            description = "playit.gg tunnel agent CLI";
            homepage = "https://playit.gg";
            license = licenses.bsd2;
            mainProgram = "playit-cli";
            platforms = platforms.unix;
          };
        };

        # This lets you run 'nix develop' to get a dev environment
        devShells.default = pkgs.mkShell {
          buildInputs = [ rustToolchain ];
        };
      }
    );
}
