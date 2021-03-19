build:
	cp config/user-config.nix ~/.config/nixpkgs/config.nix
	sudo nixos-rebuild --flake ".#" switch

system-gc:
	nix-collect-garbage

home-gc:
	home-manager expire-generations -30days
