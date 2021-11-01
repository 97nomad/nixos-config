args @ { config, lib, pkgs, unstable, ... }:

{
  programs.sway.enable = true;

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
#      wlr.enable = true;
      gtkUsePortal = true;
    };
  };
}
