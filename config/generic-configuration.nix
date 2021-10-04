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

    ## Graphics
  services.xserver = {
    enable = true;
    layout = "us,ru";
    xkbOptions = "ctrl:nocaps,grp:toggle,grp_led:caps";

    wacom.enable = true;
    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
        disableWhileTyping = true;
      };
    };

    displayManager.lightdm = {
      enable = true;
      background = "/usr/share/wallpaper.png";
      greeter.enable = true;
      greeters.gtk = {
        iconTheme.package = pkgs.paper-icon-theme;
        iconTheme.name = "Paper";
        theme.package = pkgs.adapta-gtk-theme;
        theme.name = "Adapta-Nokto-Eta";
      };
    };
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };
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
