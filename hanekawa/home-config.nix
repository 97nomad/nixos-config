args @ { config, pkgs, lib, ... }:
let
  unstable = config.also.unstable;
in
{
  home = {
    packages = with pkgs; [
      chromium unstable.tdesktop

      libreoffice inkscape

      gnome3.nautilus gnome3.file-roller
      gnome3.dconf
      feh zathura flameshot vlc rhythmbox

      dolphin

      arandr rofi rofi-pass xsecurelock
      xautolock noto-fonts xdotool pwgen

      git unstable.gitAndTools.git-bug

      direnv gnupg pass vim ag
      alacritty i3status htop gksu

      source-code-pro fira-code

      any-nix-shell

      unstable.jetbrains.idea-community postman thunderbird

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
        any-nix-shell fish --info-right | source
      '';
      functions = {
        fish_greeting = "echo 'Welcome home, mistress'";
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableFishIntegration = true;
    };

    vscode = {
      enable = true;
      package = unstable.vscodium;
      userSettings = {
        "update.channel" = "none";
        "[nix]"."editor.tabSize" = 2;
      };
      extensions = [ pkgs.vscode-extensions.bbenoist.Nix ];
    };


    emacs = import ../config/emacs.nix;

    home-manager.enable = true;
  };

  services = {
    emacs.enable = true;
    emacs.socketActivation.enable = true;

    screen-locker = {
      enable = true;
      lockCmd = "${pkgs.xsecurelock}/bin/xsecurelock";
      xautolockExtraOptions = [
        "-lockaftersleep"
        "-detectsleep"
      ];
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
    platformTheme = "gtk";
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
