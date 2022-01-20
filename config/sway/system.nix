args @ { config, lib, pkgs, unstable, ... }:

{
  environment.variables = {
    SDL_VIDEODRIVER = "wayland";
    MOZ_ENABLE_WAYLAND = "1";

    DESKTOP_SESSION = "sway";
    GTK_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "sway";

    QT_WAYLAND_DISABLE_DECORATION = "1";

    # Fixing java apps (especially idea)
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  programs.sway.enable = true;

  services.greetd = {
    enable = true;
    vt = 7;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember  --asterisks --time --greeting 'Welcome home, mistress' --cmd sway";
        user = "greeter";
      };
    };
  };


  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      wlr.enable = true;
      gtkUsePortal = true;
    };
  };
}
