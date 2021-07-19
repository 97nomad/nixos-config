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

  ## Sound
  sound.enable = true;
  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    };
  };

  ## Extra packages
  environment.systemPackages = with pkgs; [
    wireshark
  ];

  ## Fix touchpad buttons
  services.xserver.libinput.touchpad.additionalOptions = ''
    Option "ButtonMapping" "1 0 3 4 5 6 7"
  '';

  users.defaultUserShell = pkgs.fish;
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

  services.elasticsearch.enable = true;
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
}
