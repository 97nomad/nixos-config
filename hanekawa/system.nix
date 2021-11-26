{ config, pkgs, ... }:
{
  ## Nix
  nix.trustedUsers = ["root" "nommy"];

  ## Use systemd-boot EFI bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ## Чтобы PC Speaker не становился устройством по-умолчанию
  boot.blacklistedKernelModules = [ "snd_pcsp" ];

  ## Network
  networking.hostName = "hanekawa";

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

  ## Extra packages
  environment.systemPackages = with pkgs; [
    wireshark
  ];

  users.users.nommy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "docker" "plugdev" "wireshark" ];
  };

  ## Ulimits для нормальной работы Lagom
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "64000";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "64000";
    }
  ];

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
        additionalOptions = ''
          Option "ButtonMapping" "1 0 3 4 5 6 7"
        '';
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


  ## Misc
  services.elasticsearch.enable = true;
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
  programs.dconf.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.at-spi2-core.enable = true;
}
