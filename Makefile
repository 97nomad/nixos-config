.PHONY: naota

NAOTA_HOST = root@naota.nekomaidtails.xyz

build:
	cp config/user-config.nix ~/.config/nixpkgs/config.nix
	sudo nixos-rebuild --flake ".#" switch -v

naota:
	nixos-rebuild --flake ".#naota" --target-host $(NAOTA_HOST) --build-host localhost switch

system-gc:
	nix-collect-garbage

home-gc:
	home-manager expire-generations -30days
