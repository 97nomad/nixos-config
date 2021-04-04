{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "naota";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens2.useDHCP = true;

  console.keyMap = "us";
  console.font = "Lat2-Terminus16";
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Moscow";

  environment.systemPackages = with pkgs; [
    wget vim git inetutils ncat tcpdump
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPorts = [ 51820 ];

  ## HAProxy
  services.haproxy.enable = true;
  services.haproxy.config = ''
    global
      maxconn 4096
      daemon

    defaults
      mode tcp
      retries 3
      timeout connect 10s
      timeout check 10s
      timeout client 1m
      timeout server 1m

    frontend http
      mode http
      bind *:80

      use_backend http_storage if { hdr(host) -i storage.nekomaidtails.xyz }
      redirect scheme https if { hdr(host) -i octopi.nekomaidtails.xyz }
      use_backend http_vespa if { hdr(host) -i vespa.nekomaidtails.xyz }

    frontend https
      mode tcp
      bind *:443

      tcp-request inspect-delay 5s
      tcp-request content accept if { req_ssl_hello_type 1 }

      use_backend bk_storage if { req_ssl_sni -i storage.nekomaidtails.xyz }
      use_backend bk_octopi if { req_ssl_sni -i octopi.nekomaidtails.xyz }
      use_backend bk_vespa if { req_ssl_sni -i vespa.nekomaidtails.xyz }

      backend http_storage
        mode http
        server storage.nekomaidtails.xyz 192.168.1.160:80

      backend bk_storage
        mode tcp
        server storage.nekomaidtails.xyz 192.168.1.160:443

      backend bk_octopi
        mode tcp
        server octopi.nekomaidtails.xyz 192.168.1.242:443

      backend http_vespa
        mode http
        server vespa.nekomaidtails.xyz 192.168.1.160:80

      backend bk_vespa
        mode tcp
        server vespa.nekomaidtails.xyz 192.168.1.160:443
  '';

  users.users.root.shell = pkgs.fish;
  users.users.nommy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "nfs" ];
    shell = pkgs.fish;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?

}

