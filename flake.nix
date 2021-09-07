{
  description = "Best nix waifu";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-doom-emacs.url = "github:vlaci/nix-doom-emacs/master";

    secrets.flake = false;
    secrets.url = "path:secrets";
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
        };
      };
}
