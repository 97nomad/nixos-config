{
  description = "Best nix waifu";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/20.09";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager/release-20.09";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, nixos-hardware, home-manager, nixpkgs-unstable, blender-bin, ... }:
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
            "${nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
            "${nixos-hardware}/dell/latitude/3480"
          ];

          hanekawa = buildSystem [
            ./config/generic-configuration.nix
            ./hanekawa/system.nix
            ./hanekawa/hardware.nix
            ./hanekawa/home.nix
            "${nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
          ];
        };
      };
}
