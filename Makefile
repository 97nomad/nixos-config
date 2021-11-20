.PHONY: naota vespa senku

NAOTA_HOST = root@naota.nekomaidtails.xyz
VESPA_HOST = root@vespa.lan
SENKU_HOST = root@senku.lan

build:
	cp config/user-config.nix ~/.config/nixpkgs/config.nix
	sudo nixos-rebuild --flake ".#" switch -v -L

naota:
	nixos-rebuild --flake ".#naota" --target-host $(NAOTA_HOST) --build-host localhost switch

vespa:
	nixos-rebuild --flake ".#vespa" --target-host ${VESPA_HOST} --build-host localhost switch

senku:
	nixos-rebuild --flake ".#senku" --target-host ${SENKU_HOST} --build-host localhost switch

system-gc:
	nix-collect-garbage

home-gc:
	home-manager expire-generations -30days
