args @ { config, pkgs, lib, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
in
{
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  home = {
    packages = with pkgs; [
      chromium unstable.tdesktop discord

      flameshot blueman

      # viewers and editors
      libreoffice feh vlc zathura
      gimp

      # gnome stuff
      gnome3.nautilus gnome3.file-roller 
      gnome3.dconf gnome3.gvfs

      arandr rofi rofi-pass xsecurelock
      xautolock xdotool pwgen

      # fonts
      noto-fonts fira-code

      git direnv gnupg pass vim i3status
      htop gksu nextcloud-client

      unstable.jetbrains.idea-community

      (import (fetchGit "https://github.com/haslersn/fish-nix-shell"))

      # Haskell things
      stack cachix
      (all-hies.selection { selector = p: {inherit (p) ghc864 ghc843; }; })

      # Rust things
      rustup
    ];

    file = {
      ".config/i3status/config".source = "/home/nommy/nixos/i3status";
      ".emacs".source = "/home/nommy/nixos/.emacs";
    };

    keyboard = {
      layout = "us,ru";
      options = [ "ctrl:nocaps" "grp:toggle" "grp_led:caps" ];
    };
  };

  programs = {
    ssh = {
      compression = true;
      enable = true;
    };

    firefox = {
      enable = true;
    };

    rofi = {
      enable = true;
      theme = "sidebar";
      terminal = "alacritty";
    };

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
        fish-nix-shell --info-right | source
      '';
    };

    direnv = {
      enable = true;
      enableFishIntegration = true;
    };

    vscode = {
      enable = true;
      userSettings = {
        "update.channel" = "none";
        "[nix]"."editor.tabSize" = 2;
      extensions = [ pkgs.vscode-extensions.bbenoist.Nix ];
      };
    };

    emacs = {
      enable = true;
      extraPackages = epkgs: with epkgs; [
        magit company nix-mode rainbow-delimiters
        dracula-theme

        ivy counsel swiper

        lsp-haskell rust-mode lsp-mode direnv
      ];
    };

    home-manager.enable = true;
  };

  services = {
    emacs.enable = true;

    blueman-applet.enable = true;

    nextcloud-client.enable = true;

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
      lockCmd = "xsecurelock";
      xautolockExtraOptions = [
        "-lockaftersleep"
        "-detectsleep"
      ];
    };

    flameshot.enable = true;
  };

  dconf.enable = true;

  gtk = {
    enable = true;
    iconTheme.package = pkgs.paper-icon-theme;
    iconTheme.name = "Paper";
    theme.package = pkgs.adapta-gtk-theme;
    theme.name = "Adapta-Nokto-Eta";
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  xsession = {
    enable = true;
    windowManager = {
      i3.enable = true;
      i3.package = pkgs.i3-gaps;
      i3.config = import ~/nixos/i3-config.nix args;
    };
  };
}
