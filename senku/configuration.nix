{ config, pkgs, lib, inputs, unstable, ... }:

let
  secrets = (import ./secrets.nix) {};
in
{
  nix.autoOptimiseStore = true;

  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/klipper.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/moonraker.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/fluidd.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/misc/ids.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/web-servers/nginx/default.nix"
  ];
  disabledModules = [
    "services/misc/klipper.nix"
    "misc/ids.nix"
    "services/web-servers/nginx/default.nix"
  ];

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      moonraker = unstable.moonraker;
      klipper = unstable.klipper;
      fluidd = unstable.fluidd;
    };
  };

  # Enable SSH
  services.sshd.enable = true;
  users.extraUsers.nommy.openssh.authorizedKeys.keys = [ secrets.multiuserAuthorizedKey ];
  users.users.root.openssh.authorizedKeys.keys = [ secrets.multiuserAuthorizedKey ];

  # Networking
  networking = {
    hostName = "senku";
    firewall = {
      enable = false;
      allowPing = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
      networks = {
        "GLaDOS" = { psk = secrets.wifi.password; };
      };
    };
  };

  # Time
  time.timeZone = "Europe/Moscow";
#  services.ntp.enable = true;

  # Software
  environment.systemPackages = with unstable; [
    wget git screenfetch lm_sensors libraspberrypi

    htop

#    tinygo python2
  ];

  programs.fish = {
    enable = true;
    shellInit = ''
      set -g fish_greeting "There's nothing you can't do if you try!"
    '';
  };

  # Printer
  services.klipper = {
    enable = true;
    settings = {
      mcu = {
        serial = "/dev/serial/by-id/usb-Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller_0001-if00-port0";
      };

      virtual_sdcard = {
        path = "/klipper_storage";
      };

      stepper_x = {
        step_pin = "PF0";
        dir_pin = "PF1";
        enable_pin = "!PD7";
#        step_distance = ".0125";
        microsteps = "16";
        rotation_distance = "40";
        endstop_pin = "^!PE5";
        position_min = "-5";
        position_endstop = "-5";
        position_max = "210";
        homing_speed = "30.0";
      };

      stepper_y = {
        step_pin = "PF6";
        dir_pin = "!PF7";
        enable_pin = "!PF2";
#        step_distance = ".0125";
        microsteps = "16";
        rotation_distance = "40";
        endstop_pin = "^!PL7";
        position_endstop = "0";
        position_max = "210";
        homing_speed = "30.0";
      };

      stepper_z = {
        step_pin = "PL3";
        dir_pin = "!PL1";
        enable_pin = "!PK0";
#        step_distance = ".0025";
        microsteps = "16";
        rotation_distance = "8";
        endstop_pin = "^!PD3";
        position_endstop = "0.0";
        position_max = "205";
        homing_speed = "3.0";
        position_min = "-0.5";
      };

      stepper_z1 = {
        step_pin = "PC1";
        dir_pin = "!PC3";
        enable_pin = "!PC7";
#        step_distance = ".0025";
        microsteps = "16";
        rotation_distance = "8";
        endstop_pin = "^!PL6";
      };

      extruder = {
        step_pin = "PA4";
        dir_pin = "!PA6";
        enable_pin = "!PA2";
        microsteps = "16";
        rotation_distance = "7.923940992";
        nozzle_diameter = "0.350";
        filament_diameter = "1.750";
        heater_pin = "PB4";
        sensor_type = "ATC Semitec 104GT-2";
        sensor_pin = "PK5";
        min_extrude_temp = "150";
        min_temp = "0";
        max_temp = "270";
        pressure_advance = "0.4644";
        pressure_advance_smooth_time = "0.040";
        control = "pid";
        pid_kp = "29.951";
        pid_ki = "1.322";
        pid_kd = "169.600";
      };

      "heater_fan extruder_fan" = {
        pin = "PL5";
      };

      heater_bed = {
        heater_pin = "PH5";
        sensor_type = "EPCOS 100K B57560G104F";
        sensor_pin = "PK6";
        min_temp = "0";
        max_temp = "110";
        control = "pid";
        pid_kp = "73.517";
        pid_ki = "2.323";
        pid_kd = "581.701";
      };

      fan = {
        pin = "PH6";
      };

      printer = {
        kinematics = "cartesian";
        max_velocity = "300";
        max_accel = "3000";
        max_z_velocity = "10";
        max_z_accel = "60";
      };

      pause_resume = {};

      display_status = {};

      "heater_fan stepstick_fan" = {
        pin = "PH4";
      };

      "gcode_macro CANCEL_PRINT" = {
        description = "Cancel the actual running print";
        rename_existing = "CANCEL_PRINT_BASE";
        gcode = [
          "TURN_OFF_HEATERS"
          "CANCEL_PRINT_BASE"
        ];
      };

      "filament_switch_sensor filament_sensor" = {
        pause_on_runout = "True";
        runout_gcode = [
          "M118 Filament Runout Detected"
        ];
        insert_gcode = [
          "M118 Filament Load Detected"
        ];
        switch_pin = "^!PD2";
      };
    };
  };

  services.moonraker = {
    enable = true;
    address = "0.0.0.0";
    user = "klipper";
    group = "klipper";
    settings = {
      "authorization" = {
        "trusted_clients" = secrets.moonraker.trusted_clients;
      };
      octoprint_compat = {};
    };
  };
  services.fluidd = {
    enable = true;
    hostName = "senku";
    nginx.listenAddresses = [ "0.0.0.0" ];
  };

  # Users
  users.defaultUserShell = pkgs.fish;
  users.users.nommy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  services.nginx = {
    enable = true;
    clientMaxBodySize = "1G";
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };
  services.nginx.virtualHosts = {
    "senku" = {
    };
  };

}
