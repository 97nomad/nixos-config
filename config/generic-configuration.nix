{ config, pkgs, ...}:

{
  nixpkgs.config.allowUnfree = true;

  nix = {
    trustedUsers = [ "root" "nommy" ];
    autoOptimiseStore = true;
    package = pkgs.nixFlakes;
    nixPath = [ "nixpkgs=${pkgs.path}" ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  networking = {
    networkmanager = {
      enable = true;

      packages = with pkgs; [
        networkmanagerapplet
        networkmanager-openvpn
        networkmanager-openconnect
      ];
    };
  };

  ## Internationalization
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Moscow";

  environment.systemPackages = with pkgs; [
    wget vim git gvfs glib gnumake
    killall lsof htop
  ];

  ## Misc
  services.openssh.enable = true;

  ## System version
  system.stateVersion = "21.11";
}
