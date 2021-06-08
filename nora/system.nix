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
  ];

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
      extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
      ];
    };
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull.override {
        jackaudioSupport = true;
      };
      support32Bit = true;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      extraConfig = ''
        load-module module-switch-on-connect

        load-module module-jack-sink channels=2
        load-module module-jack-source channels=2
        set-default-sink jack_out
      '';
    };
  };

  services.jack = {
    jackd.enable = true;
    alsa.enable = false;
    loopback.enable = true;
  };
  systemd.user.services.pulseaudio.environment = {
    JACK_PROMISCUOUS_SERVER = "jackaudio";
  };

  ## Users
  users.defaultUserShell = pkgs.fish;
  users.users.nommy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "adbusers" "plugdev" "nitrokey" "jackaudio" "docker" "plugdev" "dialout" "bluetooth" ];
  };

  ## Misc
  hardware.nitrokey.enable = true;
  programs.steam.enable = true;

  ## Power management
  ### Disable upower and systemd handlers and let acpid rule them all
  services = {
    acpid = {
      enable = true;
      lidEventCommands = "systemctl suspend";
    };
    logind.lidSwitch = "ignore";
  };

  ## udev
  services.udev.packages = [
    pkgs.android-udev-rules
    pkgs.rtl-sdr
  ];

  ## Android
  programs.adb.enable = true;

  virtualisation.docker.enable = false;

  ## TFTP
  services.tftpd = {
    enable = true;
  };
}

