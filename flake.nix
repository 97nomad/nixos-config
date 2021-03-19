{
  description = "Just Nora";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/20.09";
    nixos-hardware.url = "github:nixos/nixos-hardware";
#    home-manager.url = "github:nix-community/home-manager/master";
#    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, nixos-hardware }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
      };
      buildConfig = modules: { inherit modules system specialArgs; };
      buildSystem = modules: lib.nixosSystem (buildConfig modules);
    in
      {
        nixosConfigurations = {
          nora = buildSystem [
            ./generic-configuration.nix
            ./nora-system.nix
            ./nora-hardware.nix
            "${nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
            "${nixos-hardware}/dell/latitude/3480"
          ];

          hanekawa = buildSystem [
            ./generic-configuration.nix
            ./hanekawa-config.nix
            "${nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
          ];
        };
      };
}
