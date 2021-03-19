{ pkgs, config, inputs, ... }:
{
  
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true;
    home-manager.users.nommy = import ./home-config.nix;
  };
}
