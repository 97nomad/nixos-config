args @ { config, lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      swaylock-effects
      swayidle
      wl-clipboard
      mako
      grim
      slurp
    ];
  };

  systemd.user.sessionVariables = config.home.sessionVariables;

  home.sessionVariables = {
    # for some reason it doesn't want to read anything else
    SDL_VIDEODRIVER = "wayland";

    # self-descriptive
    MOZ_ENABLE_WAYLAND = "1";

    # actually I'm sure it's set somewhere else too
    DESKTOP_SESSION = "sway";
    GTK_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "sway";

    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Fixing java apps (especially idea)
    _JAVA_AWT_WM_NONREPARENTING = "1";

    # Some wlr variables, https://gitlab.freedesktop.org/wlroots/wlroots/-/blob/master/docs/env_vars.md
    # WLR_DRM_NO_MODIFIERS = "1";
    #
  };

  programs = {
    waybar = {
      enable = true;

      settings = [
        {
          layer = "top";
          position = "bottom";
          height = 16;

          modules-left = [ "sway/workspaces" ];
          modules-right = [
            "idle_inhibitor"
            "custom/separator"
            "pulseaudio"
            "custom/separator"
            "network"
            "custom/separator"
            "battery"
            "custom/separator"
            "disk"
            "custom/separator"
            "cpu"
            "custom/separator"
            "clock"
            "custom/separator"
            "tray"
          ];

          modules = {
            "clock" = {
              format = "{:%Y-%m-%d %T}";
              interval = 5;
            };
            "battery" = {
              format = "{capacity}% {time}";
              format-time = "{H}:{M}";
              design-capacity = true;
            };
            "disk" = {
              format = " {free} ";
            };
            "network" = {
              format = "{ifname}: {ipaddr}";
              format-wifi = "{essid} ({signalStrength}%) ";
              format-ethernet = "{ifname} ";
              format-disconnected = "";
              tooltip-format = "{ifname}: {ipaddr}";
            };
            "pulseaudio" = {
              format = "♪: {volume}%";
              format-muted = "♪: muted {volume}%";
            };
            "sway/workspaces" = {
              disable-scroll = true;
              all-outputs = true;
            };
            "idle_inhibitor" = {
              format = "{icon}";
              format-icons = {
                activated = "";
                deactivated = "";
              };
            };
            "custom/separator" = {
              format = "♥";
              interval = "once";
              tooltip = false;
            };
          };
        }
      ];

      style = builtins.readFile ./sway.css;
    };

    mako = {
      enable = true;
      borderSize = 0;
      backgroundColor = "#125522aa";
    };
  };

  services = {
    kanshi.enable = true;
  };

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    config = import ./sway-config.nix args;
  };

  gtk = {
    enable = true;

    iconTheme.package = pkgs.gnome3.adwaita-icon-theme;
    iconTheme.name = "Adwaita";

    font.name = "Noto Sans";
    font.size = 10;

    gtk2.extraConfig = ''
      gtk-enable-animations=1
      gtk-primary-button-warps-slider=0
      gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
      gtk-cursor-theme-name=Paper
      gtk-menu-images=1
      gtk-button-images=1
    '';
    theme.package = pkgs.adapta-gtk-theme;
    theme.name = "Adapta-Nokto-Eta";
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
    style.name = "gtk2";
  };

}
