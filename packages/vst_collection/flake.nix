{
  description = "Nommy's VST collection";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    vst2.url = "/home/nommy/nixres/vst_collection";
    vst2.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, vst2 }:
    let out = system:
    let pkgs = nixpkgs.legacyPackages."${system}";
    in {
      defaultPackage = pkgs.stdenv.mkDerivation {
        name = "VSTCollection";
        version = "1.0.1";
        src = vst2;

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
        ];

        buildInputs = with pkgs; [
          freetype
          gcc-unwrapped
          alsa-lib
          libglvnd
        ];

        unpackPhase = "true";

        installPhase = ''
          mkdir -p $out

          cp -r $src/vst2 $out/
        '';
      };

      nixosModule = { config, ... }: with nixpkgs.lib; {
        config = {
          home.file.".vst".source = "${self.defaultPackage."${system}"}/vst2";
        };
      };
    }; in with flake-utils.lib; eachSystem defaultSystems out;
}
