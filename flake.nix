{
  description = "Best nix waifus";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs/master";
    tg-scrum-poker.url = "github:97nomad/TgScrumPoker";

    waveform.url = "path:packages/waveform";
    waveform.inputs.nixpkgs.follows = "nixpkgs";

    vst_collection.url = "path:packages/vst_collection";
    vst_collection.inputs.nixpkgs.follows = "nixpkgs";

    valetudoMapCard.url = "github:TheLastProject/lovelace-valetudo-map-card/master";
    valetudoMapCard.flake = false;

    secrets.url = "/home/nommy/nixres/secrets";
    secrets.flake = false;
  };

  outputs = inputs @ { self, nixpkgs, nixos-hardware, home-manager, nixpkgs-unstable, secrets, blender-bin, nix-doom-emacs, ... }:
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
            ./config/zsh.nix
            ./config/pipewire.nix
            ./config/sway/system.nix
            ./nora/system.nix
            ./nora/hardware.nix
            ./nora/home.nix
            nixos-hardware.nixosModules.dell-latitude-3480
          ];

          hanekawa = buildSystem [
            ./config/generic-configuration.nix
            ./config/zsh.nix
            ./config/pipewire.nix
            ./hanekawa/system.nix
            ./hanekawa/hardware.nix
            ./hanekawa/home.nix
          ];

          naota = buildSystem [
            ./config/generic-configuration.nix
            ./config/zsh.nix
            ./naota/system.nix
            ./naota/hardware.nix
            "${secrets}/naota.nix"
            "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
          ];

          vespa = armBuildSystem [
            ./config/zsh.nix
            ./vespa/configuration.nix
            ./vespa/hardware-configuration.nix
          ];

          senku = armBuildSystem [
            ./config/zsh.nix
            ./senku/configuration.nix
            ./senku/hardware-configuration.nix
          ];
        };
      };
}
