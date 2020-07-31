{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ## Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  ## Nix
  nix = {
    trustedUsers = [ "root" "nommy" ];
    autoOptimiseStore = true;
  };

  ## Network
  networking = {
    hostName = "neko-maid";
    networkmanager = {
      enable = true;

      packages = with pkgs; [
        networkmanagerapplet
        networkmanager-openvpn
      ];
    };

    # Ports:
    # 22 - SSH
    # 1714-1764 - KDE Connect
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 22 ];
      allowedTCPPortRanges = [
        { from=1714; to=1764; }
      ];
      allowedUDPPortRanges = [
        { from=1714; to=1764; }
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
  services.ntp.enable = true;

  ## Packages
  environment.systemPackages = with pkgs; [
    wget vim git gvfs glib gnumake nitrokey-udev-rules
  ];

  ## Shells
  environment.shells = with pkgs; [
    fish
  ];

  ## Bluetooth
  services.blueman.enable = true;

  ## Sound and Video
  sound = {
    enable = true;
    enableOSSEmulation = true;
  };
  hardware = {
    cpu.intel.updateMicrocode = true;
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    };
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      support32Bit = true;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
    };
    bluetooth.enable = true;
  };

  services.jack = {
    jackd.enable = true;
    alsa.enable = false;
    loopback.enable = true;
  };
  systemd.user.services.pulseaudio.environment = {
    JACK_PROMISCUOUS_SERVER = "jackaudio";
  };

  ## Graphics
  services.xserver = {
    enable = true;
    layout = "us,ru";
    xkbOptions = "ctrl:nocaps,grp:toggle,grp_led:caps";

    wacom.enable = true;
    libinput = {
      enable = true;
      naturalScrolling = true;
      disableWhileTyping = true;
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

  ## Users
  users.defaultUserShell = pkgs.fish;
  users.users.nommy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "adbusers" "plugdev" "nitrokey" "jackaudio" ];
  };

  ## Misc
  services = {
    openssh.enable = true;
    upower.enable = true;
  };
  hardware.nitrokey.enable = true;
  environment.variables.MOZ_USE_XINPUT2 = "1";
  programs.dconf.enable = true;
  services.gnome3.gnome-keyring.enable = true;

  ## Android
  programs.adb.enable = true;
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?

}

