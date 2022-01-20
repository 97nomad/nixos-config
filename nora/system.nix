{ config, pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ## Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  ## Nix
  nix.trustedUsers = ["root" "nommy"];

  ## Network
  networking = {
    hostName = "nora";

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
      allowedUDPPorts = [ 69 ];
      allowedUDPPortRanges = [
        { from=1714; to=1764; }
      ];
    };
  };

  ## Packages
  environment.systemPackages = with pkgs; [
    # Power management
    powertop acpid

    # RTL-SDR
    libusb rtl-sdr gqrx

    libudev

    freetype gcc11
  ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    opengl = {
      enable = true;
      setLdLibraryPath = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
        intel-media-driver
        libva
        libvdpau
        libvdpau-va-gl
        mesa
        rocm-opencl-icd
        vaapiIntel
        vaapiVdpau
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
        intel-media-driver
        libva
        libvdpau
        driversi686Linux.libvdpau-va-gl
        driversi686Linux.mesa
        rocm-opencl-icd
        driversi686Linux.vaapiIntel
        driversi686Linux.vaapiVdpau
      ];
    };
  };
  services.xserver.videoDrivers = [ "intel" ];

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

  ## Users
  users.users.nommy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "adbusers" "plugdev" "nitrokey" "jackaudio" "docker" "plugdev" "dialout" "bluetooth" ];
  };

  ## Misc
  hardware.nitrokey.enable = true;
  programs.steam.enable = true;
  environment.variables.MOZ_USE_XINPUT2 = "1";
  programs.dconf.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.at-spi2-core.enable = true;

  ## Power management
  services.logind.lidSwitch = "suspend";

  ## udev
  services.udev.packages = [
    pkgs.android-udev-rules
    pkgs.rtl-sdr
  ];

  ## Android
  programs.adb.enable = true;

  virtualisation.docker.enable = false;

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
  };

  ## TFTP
  services.tftpd = {
    enable = true;
  };
}

