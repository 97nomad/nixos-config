.PHONY: system-copy system-rebuild system home-rebuild home

system-copy:
	cp nora-system.nix /etc/nixos/nora-system.nix
	cp generic-configuration.nix /etc/nixos/generic-configuration.nix
	cp nora-hardware.nix /etc/nixos/nora-hardware.nix
	cp flake.nix /etc/nixos/flake.nix

system-rebuild:
	nixos-rebuild switch

system: system-copy system-rebuild

home-rebuild:
	cp user-config.nix ~/.config/nixpkgs/config.nix
	cp home.nix ~/.config/nixpkgs/home.nix
	home-manager switch

home: home-rebuild

system-gc:
	nix-collect-garbage

home-gc:
	home-manager expire-generations -30days
