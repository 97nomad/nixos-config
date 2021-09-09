{ config, lib, pkgs, ... }:

{
  boot.loader.grub.enable = false;
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 4;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  boot.kernelParams = [
    "cma=64M"
    "console=tty0"
  ];

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      priority = 100;
      size = 2048;
    }
  ];

  hardware.enableRedistributableFirmware = true;
}
