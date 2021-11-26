{
  description = "The “Quite OK Image” format for fast, lossless image compression";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let out = system:
    let
      pkgs = nixpkgs.legacyPackages."${system}";
      version = "0.0.1";
    in {
      defaultPackage = pkgs.stdenv.mkDerivation {
        name = "qoi";
        inherit version;
        src = builtins.fetchGit {
          url = "https://github.com/phoboslab/qoi";
          rev = "dd0b04b319573609737044d0e6cf9927786a3019";
        };

        buildInputs = with pkgs; [
          stb
        ];

        buildPhase = ''
          $CC qoiconv.c -I${pkgs.stb}/include/stb
        '';

        installPhase = ''
          cp a.out $out
        '';
      };
    }; in with flake-utils.lib; eachSystem ["x86_64-linux"] out;
}
