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

  ## Shells
  environment.shells = with pkgs; [
    fish
  ];

  ## Bluetooth
  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };

  ## Screen brightness
  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
    ];
  };

  ## Misc
  services.openssh.enable = true;
  environment.variables.MOZ_USE_XINPUT2 = "1";
  programs.dconf.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.at-spi2-core.enable = true;

  ## System version
  system.stateVersion = "20.09";
}
