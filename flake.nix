{
  description = "Best nix waifu";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-doom-emacs.url = "github:vlaci/nix-doom-emacs/master";

    tg-scrum-poker.url = "github:97nomad/TgScrumPoker";

    waveform.url = "path:packages/waveform";
    waveform.inputs.nixpkgs.follows = "nixpkgs";

    valetudoMapCard.url = "github:TheLastProject/lovelace-valetudo-map-card/master";
    valetudoMapCard.flake = false;

    secrets.flake = false;
    secrets.url = "path:secrets";
  };

  outputs = inputs @ { self, nixpkgs, nixos-hardware, home-manager, nixpkgs-unstable, secrets, blender-bin, nix-doom-emacs, tg-scrum-poker, ... }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        nixpkgs.config.allowUnfree = true;
        unstable = (import nixpkgs-unstable {
          inherit system;
          config = { allowUnfree = true; };
        });
      };
      buildConfig = modules: { inherit modules system specialArgs; };
      buildSystem = modules: lib.nixosSystem (buildConfig modules);

      armSystem = "aarch64-linux";
      armSpecialArgs = {
        inherit inputs;
        nixpkgs.config.allowUnfree = true;
        unstable = (import nixpkgs-unstable {
          system = armSystem;
          config = { allowUnfree = true; };
        });
      };
      armBuildConfig = modules: { inherit modules; system = armSystem; specialArgs = armSpecialArgs; };
      armBuildSystem = modules: lib.nixosSystem (armBuildConfig modules);
    in
      {
        nixosConfigurations = {
          nora = buildSystem [
            ./config/generic-configuration.nix
            ./nora/system.nix
            ./nora/hardware.nix
            ./nora/home.nix
            nixos-hardware.nixosModules.dell-latitude-3480
          ];

          hanekawa = buildSystem [
            ./config/generic-configuration.nix
            ./hanekawa/system.nix
            ./hanekawa/hardware.nix
            ./hanekawa/home.nix
          ];

          naota = buildSystem [
            ./config/generic-configuration.nix
            ./naota/system.nix
            ./naota/hardware.nix
            "${secrets}/naota.nix"
            "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
          ];

          vespa = armBuildSystem [
            ./vespa/configuration.nix
            ./vespa/hardware-configuration.nix
          ];
        };
      };
}
