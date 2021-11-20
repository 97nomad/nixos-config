{ config, pkgs, lib, inputs, unstable, ... }:

let
  valetudoMapCard = inputs.valetudoMapCard;
  miniMediaPlayerCard = builtins.fetchurl {
    url = "https://github.com/kalkih/mini-media-player/releases/download/v1.12.0/mini-media-player-bundle.js";
    sha256 = "170x5x4x0lv71k6lxl8hpcy6q9sqds4nc60njksc5dlhcnk4408h";
  };

  secrets = (import ./secrets.nix) {};
in
{
  nix.autoOptimiseStore = true;

  environment.etc."mdadm/mdadm.conf".text = ''
    DEVICE partitions
    ARRAY /dev/md0 level=raid1 num-devices=2 metadata=1.2 name=vespa:0 UUID=343275ca:3ea628af:6b4308a6:c9126db2
  '';

  fileSystems."/storage" = {
    device = "/dev/md0";
    fsType = "ext4";
    options = [ "x-systemd.automount" "noauto" ];
  };

  # Enable SSH
  services.sshd.enable = true;
  users.extraUsers.nommy.openssh.authorizedKeys.keys = [ secrets.multiuserAuthorizedKey ];
  users.users.root.openssh.authorizedKeys.keys = [ secrets.multiuserAuthorizedKey ];

  # Networking
  networking = {
    hostName = "vespa";
    firewall = {
      enable = false;
      allowPing = true;
      allowedTCPPorts = [ 22 80 443 1883 6680 ];
      allowedUDPPorts = [ 1883 ];
    };
  };
  boot.kernel.sysctl."net.ipv6.conf.eth0.disable_ipv6" = true;

  # Bluetooth
  services.blueman.enable = false;
  hardware.bluetooth = {
    enable = true;
    package = unstable.bluezFull;
  };

  # Audio
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    systemWide = true;
    package = unstable.pulseaudioFull;
    extraModules = with unstable; [ pulseaudio-modules-bt ];
    extraConfig = ''
      load-module module-switch-on-connect

      load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1
    '';
  };
  boot.loader.raspberryPi.firmwareConfig = ''
    dtparam=audio=on
  '';


  # Time
  time.timeZone = "Europe/Moscow";
  services.ntp.enable = true;

  # Software
  environment.systemPackages = with unstable; [
    wget git screenfetch lm_sensors libraspberrypi

    htop inetutils ncat tcpdump

    ffmpeg imagemagick ghostscript

    youtube-dl mopidy
  ];

  programs.fish = {
    enable = true;
    shellInit = ''
      set -g fish_greeting "It takes an idiot to do cool things. That's why it's cool."
    '';
  };

  # Users
  users.defaultUserShell = pkgs.fish;
  users.users.root.extraGroups = [ "audio" ];
  users.users.mopidy.extraGroups = [ "audio" "nextcloud" ];
  users.users.nommy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" ];
  };
  users.users.nextcloud = {
    extraGroups = [ "nginx" "nextcloud" ];
  };

  # motd
  security.pam.services.sshd.showMotd = true;
  users.motd = ''
 __      ________  _____ _____        
 \ \    / /  ____|/ ____|  __ \ /\    
  \ \  / /| |__  | (___ | |__) /  \   
   \ \/ / |  __|  \___ \|  ___/ /\ \  
    \  /  | |____ ____) | |  / ____ \ 
     \/   |______|_____/|_| /_/    \_\
                                                                            
  '';

  # Nextcloud
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_11;
    dataDir = "/storage/postgres";
    ensureDatabases = [ "nextcloud" "hass" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      }
      {
        name = "hass";
        ensurePermissions."DATABASE hass" = "ALL PRIVILEGES";
      }
    ];
  };

  services.nextcloud = {
    enable = true;
    home = "/storage/nextcloud";
    hostName = "storage.nekomaidtails.xyz";
    https = true;
    maxUploadSize = "16G";
    package = pkgs.nextcloud22;

    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "05:00:00";

    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      adminpass = secrets.nextcloud.adminpass;
      adminuser = secrets.nextcloud.adminuser;
      overwriteProtocol = "https";
    };
  };

  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };
  services.nginx.virtualHosts = {
    "storage.nekomaidtails.xyz" = {
      forceSSL = true;
      enableACME = true;
    };
    "iris.nekomaidtails.xyz" = {
      locations = {
        "/" = {
          proxyPass = "http://localhost:6680/iris/";
          proxyWebsockets = true;
        };
        "/mopidy/" = {
          proxyPass = "http://localhost:6680";
          proxyWebsockets = true;
        };
        "/iris/" = {
          proxyPass = "http://localhost:6680/iris/";
          proxyWebsockets = true;
        };
      };
    };
    "vespa.nekomaidtails.xyz" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8123";
        proxyWebsockets = true;
      };
    };
  };
  security.acme.acceptTerms = true;
  security.acme.certs = {
    "storage.nekomaidtails.xyz" = {
      email = "97nomad@gmail.com";
    };
    "vespa.nekomaidtails.xyz" = {
      email = "97nomad@gmail.com";
    };
  };

  ## Nextcloud dowloaders
  services.aria2 = {
    enable = false;
    rpcSecret = secrets.aria2.rpcSecret;
    openPorts = false;
    downloadDir = "/storage/aria2";
  };
  systemd.services.aria2.serviceConfig.Group = lib.mkForce "nextcloud";

  ## MPD
  services.mopidy = {
    enable = true;
    dataDir = "/storage/mopidy";
    extensionPackages = with unstable; [
      mopidy-local mopidy-iris mopidy-mpd mopidy-youtube
    ];
   configuration = ''
      [mpd]
      hostname = 127.0.0.1

      [audio]
      output = pulsesink server=127.0.0.1

      [local]
      media_dir = /storage/nextcloud/data/nommy/files/Music/
    '';
  };
  systemd.services.mopidy.environment."XDG_RUNTIME_DIR" = "/run/user/${toString config.users.users.mopidy.uid}";

  ## MPRIS proxy for bluetooth
  #systemd.services.mpris-proxy = {
  #  Unit.Description = "Mpris proxy";
  #  Unit.After = [ "network.target" "sound.target" ];
  #  Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  #  Install.WantedBy = [ "default.target" ];
  #};

  ## Home Assistant
  services.mosquitto = {
    enable = true;
    host = "0.0.0.0";
    checkPasswords = true;
    users = {
      glados = {
        acl = [ "topic readwrite valetudo/#" "topic readwrite homeassistant/#" ];
        password = secrets.mqtt.glados;
      };
      hass = {
        acl = [ "topic readwrite #" ];
        password = secrets.mqtt.hass;
      };
      aircontrol = {
        acl = [ "topic readwrite aircontrol/#" "topic readwrite homeassistant/#" ];
        password = secrets.mqtt.aircontrol;
      };
      sagiri = {
        acl = [ "topic readwrite sagiri/#" "topic readwrite homeassistant/#" ];
        password = secrets.mqtt.sagiri;
      };
    };
  };

  services.home-assistant = {
    enable = true;
    openFirewall = false;
    package = (unstable.home-assistant.overrideAttrs (old: {
      doCheck = false;
      checkPhase = ":";
      installCheckPhase = ":";
    })).override {
      extraPackages = ps: with ps; [
        python-forecastio jsonrpc-async jsonrpc-websocket mpd2 pkgs.picotts psycopg2
      ];
    };
    configDir = "/storage/home-assistant";
    config = {
      frontend = {};
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" "::1" ];
      };
      homeassistant = {
        name = "Home";
        unit_system = "metric";
        time_zone = "Europe/Moscow";
      };

      recorder = {
        db_url = "postgresql://@/hass";
        include = {
          domains = [ "sensor" ];
        };
      };
      history = {
        include = {
          domains = [ "sensor" ];
        };
      };

      tts = [
        { platform = "google_translate";
          cache = true;
          cache_dir = "/tmp/tts";
          base_url = "https://vespa.nekomaidtails.xyz";
          language = "ru";
          time_memory = 57600;
          service_name =  "google_say";
        }
      ];

      mobile_app = {};

      media_player = [
        {
          platform = "mpd";
          name = "raspberry";
          host = "127.0.0.1";
        }
      ];

      mqtt = {
        broker = "localhost";
        discovery = true;
        discovery_prefix = "homeassistant";
        username = "hass";
        password = secrets.mqtt.hass;
      };

      octoprint = [{
        name = "Anycubic i3 Mega S";
        host = "octopi.nekomaidtails.xyz";
        ssl = true;
        port = 443;
        api_key = secrets.octoprint.apiKey;

        bed = true;
        number_of_tools = 1;
      }];

      camera = [
        {
          platform = "generic";
          name = "Sagiri";
          username = secrets.sagiri.user;
          password = secrets.sagiri.password;
          authentication = "basic";
          still_image_url = "https://sagiri/cgi-bin/currentpic.cgi";
          stream_source = "rtsp://sagiri:8554/unicast";
          verify_ssl = false;
          scan_interval = 5;
          framerate = 15;
        }
      ];
    };
  };

  ## Custom HA modules
  system.activationScripts.hassLovelaceModules = ''
    cp --remove-destination ${valetudoMapCard}/valetudo-map-card.js /storage/home-assistant/www/valetudo-map-card.js
    cp --remove-destination ${miniMediaPlayerCard} /storage/home-assistant/www/mini-media-player-bundle.js
  '';
}
