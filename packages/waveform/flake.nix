{
  description = "Waveform";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    debFile.url = "path:/home/nommy/nixres/waveform/waveform_64bit_v11.5.18.deb";
    debFile.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, debFile }:
    let out = system:
    let pkgs = nixpkgs.legacyPackages."${system}";
    in {
      defaultPackage = pkgs.stdenv.mkDerivation {
        name = "Waveform11";
        version = "11.5.18";
        src = debFile;

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
          dpkg
        ];

        buildInputs = with pkgs; [
          glibc
          gcc-unwrapped
          alsa-lib
          freetype
          libglvnd
          curl
        ];

        unpackPhase = "true";

        installPhase = ''
          mkdir -p $out
          dpkg -x $src $out
          patchelf --add-needed libcurl.so $out/usr/bin/Waveform11

          mkdir $out/bin
          ln -s $out/usr/bin/Waveform11 $out/bin/
        '';
      };
    }; in with flake-utils.lib; eachSystem ["x86_64-linux"] out;
}
