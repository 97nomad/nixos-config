.PHONY: system-copy system-rebuild system home-rebuild home

system-copy:
	cp configuration.nix /etc/nixos/configuration.nix
	cp hardware-configuration.nix /etc/nixos/hardware-configuration.nix

system-rebuild:
	nix-channel --update
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
