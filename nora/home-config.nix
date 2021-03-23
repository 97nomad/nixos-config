args @ { config, pkgs, lib, ... }:
let
  unstable = config.also.unstable;
  blender-bin = config.also.inputs.blender-bin.defaultPackage.${pkgs.system};
in
{
  home = {
    packages = with pkgs; [
      blender-bin

      #unstable
      unstable.tdesktop unstable.super-slicer
      unstable.jetbrains.idea-community

      chromium discord

      flameshot blueman

      (steam.override {
        extraPkgs = pkgs: with pkgs; [
         nghttp2 libidn2 rtmpdump libpsl
        ];
      })

      # Viewers and editors
      libreoffice
      feh vlc zathura
      gimp freecad inkscape krita
      kicad openscad lmms

      # gnome stuff
      gnome3.nautilus gnome3.file-roller 
      gnome3.dconf gnome3.gvfs ffmpeg ffmpegthumbnailer
      gst_all_1.gst-libav unrar gnome3.eog gnome3.shotwell

      arandr rofi rofi-pass xsecurelock xss-lock
      xautolock xdotool pwgen

      # fonts
      noto-fonts fira-code

      # themes
      adapta-gtk-theme adapta-kde-theme

      git direnv gnupg vim i3status
      htop gksu nextcloud-client browserpass

      (pass.withExtensions(e: with e; [
        pass-otp pass-genphrase pass-audit
      ]))

      #unstable.jetbrains.idea-community

      any-nix-shell

      kdeconnect nix-index nixops ag

      ## Music
      vmpk qsynth qjackctl

      ## Video and photo
      openshot-qt

      ## Docker
      docker-compose

      ## Hardware monitoring
      lm_sensors

      qbittorrent cura simplescreenrecorder onboard

      ## SDR
      urh gqrx rtl_433

      ## Piano
      lenmus musescore rhythmbox

      # Better Emacs
      (writeShellScriptBin "ee" ''
        ${emacs}/bin/emacsclient -s /run/user/1000/emacs/server -c $@
      '')

      (writeShellScriptBin "ec" ''
        ${emacs}/bin/emacsclient -s /run/user/1000/emacs/server -nc $@
      '')
    ];

    file = {
      ".config/i3status/config".source = ../config/i3status;
      ".emacs".source = ../config/.emacs;
    };

    keyboard = {
      layout = "us,ru";
      options = [ "ctrl:nocaps" "grp:toggle" "grp_led:caps" ];
    };
  };

  programs = {
    ssh = {
      enable = true;
      compression = true;
      matchBlocks.vespa = {
        hostname = "storage.nekomaidtails.xyz";
        identityFile = "~/.ssh/id_rsa";
      };
    };

    firefox = {
      enable = true;
    };

    rofi = {
      enable = true;
      theme = "sidebar";
      terminal = "alacritty";
    };

    browserpass.enable = true;
    browserpass.browsers = [ "firefox" ];

    alacritty = {
      enable = true;
      settings = {
        "env" = {
          "TERM" = "xterm-256color";
        };
        "window" = {
          "gtk-theme-variant" = "dark";
          "decorations" = "none";
        };
        "font" = let family = "Fira Code"; in {
          "normal" = { "family" = family; };
          "italic" = { "family" = family; };
          "bold" = { "family" = family; };
          "bold_italic" = { "family" = family; };
          "size" = 6;
        };
      };
    };

    fish = {
      enable = true;
      promptInit = ''
        any-nix-shell fish --info-right | source
      '';
      functions = {
        fish_greeting = "echo 'Welcome home, mistress'";
      };
    };

    direnv = {
      enable = true;
      enableNixDirenvIntegration= true;
      enableFishIntegration = true;
    };

    vscode = {
      enable = true;
      userSettings = {
        "update.channel" = "none";
        "[nix]"."editor.tabSize" = 2;
      };
      extensions = [
        pkgs.vscode-extensions.bbenoist.Nix
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "nix-env-selector";
          publisher = "arrterian";
          version = "0.1.1";
          sha256 = "55ab753a99b8b6390bb526d127cf7ced334108a1f14bd8ecbe6adc337da37739";
        }
        {
          name = "ide-purescript";
          publisher = "nwolverson";
          version = "0.20.8";
          sha256 = "378e2cdd4e2ff4cf403b36ad1b5d7b083f26384da95d93033134a41056ed5b99";
        }
        {
          name = "language-purescript";
          publisher = "nwolverson";
          version = "0.2.2";
          sha256 = "3f5f3632f6c7401cd75a121fa7a004eb5ce3bb14e2980470a3c8711dac302d4a";
        }
        {
          name = "rust";
          publisher = "rust-lang";
          version = "0.7.0";
          sha256 = "40f3b9200e66ad8a3a727de17538e6ce16d137f614ec6e3232ca49f9d441c79a";
        }
      ];
    };

    emacs = {
      enable = true;
      extraPackages = epkgs: with epkgs; [
        use-package

        dired-subtree

        magit company rainbow-delimiters
        dracula-theme

        ivy counsel swiper counsel-tramp

        rust-mode lsp-mode lsp-ivy direnv
        yaml-mode

        nixos-options company-nixos-options nix-mode
      ];
    };

    home-manager.enable = true;
  };

  services = {
    emacs.enable = true;
    emacs.socketActivation.enable = true;

    blueman-applet.enable = true;

    nextcloud-client.enable = true;

    kdeconnect = {
      enable = true;
      indicator = true;
    };

    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
      enableScDaemon = true;
      extraConfig = ''
        allow-emacs-pinentry
      '';
    };

    screen-locker = {
      enable = true;
      lockCmd = "${pkgs.xsecurelock}/bin/xsecurelock";
      xautolockExtraOptions = [
        "-lockaftersleep"
        "-detectsleep"
      ];
    };

    flameshot.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme.package = pkgs.paper-icon-theme;
    iconTheme.name = "Paper";
    theme.package = pkgs.adapta-gtk-theme;
    theme.name = "Adapta-Nokto-Eta";
  };
  qt = {
    enable = true;
  };

  xsession = {
    enable = true;
    windowManager = {
      i3.enable = true;
      i3.package = pkgs.i3-gaps;
      i3.config = import ../config/i3-config.nix args;
    };
  };
}
