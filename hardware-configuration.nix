# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/dell/latitude/3480"
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "snd-seq" "snd-rawmidi" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8641af94-8ca3-4e82-9d47-1c5b790b2a00";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/9886-20CD";
      fsType = "vfat";
    };
  fileSystems."/windows" = {
    device = "/dev/disk/by-uuid/8850526050525552";
    fsType = "ntfs";
    options = [ "rw" ];
  };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 8;

  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_perfomance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
  };
}
