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

    # Audio
    pavucontrol pulseaudio alsaUtils
    alsa-lib freetype gcc11
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

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;

    config.pipewire = {
      "context.properties" = {
        "default.clock.allowed-rates" = [ 48000 44100 ];
      };
    };

#    config.pipewire-pulse = {
#      "context.exec" = [
#        { path = "pactl"; args = "module-switch-on-connect"; }
#      ];
#    };

    media-session.config.bluez-monitor.rules = [
      {
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            "bluez5.msbc-support" = true;
            "bluez5.sbc-xq-support" = true;
          };
        };
      }
      {
        matches = [
          { "node.name" = "~bluez_input.*"; }
          { "node.name" = "~bluez_output.*"; }
        ];
        actions = {
          "node.pause-on-idle" = false;
        };
      }
    ];
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
  };

  ## TFTP
  services.tftpd = {
    enable = true;
  };
}

