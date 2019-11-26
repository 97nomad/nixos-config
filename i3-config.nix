{ lib, ... }:
rec {
  modifier = "Mod4";
  modes = {};

  keybindings =
  let
    mod = modifier;
    workspaces = with lib; listToAttrs (
    (map (i: nameValuePair "${mod}+${i}" "workspace number ${i}") (map toString (range 0 9))) ++
    (map (i: nameValuePair "${mod}+Shift+${i}" "move container to workspace number ${i}") (map toString (range 0 9)))
    );
  in lib.mkDefault ({
    "${mod}+Tab" = "workspace back_and_forth";
    "${mod}+Shift+q" = "kill";
    "${mod}+Return" = "exec alacritty";
    "${mod}+d" = "exec rofi -combi-mode drun#run -show combi";
    "${mod}+q" = "exec rofi-pass";
    "${mod}+Escape" = "exec xautolock -locknow";
    "${mod}+Shift+e" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";
    "${mod}+Print" = "exec flameshot gui";

    "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume 0 +5%";
    "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume 0 -5%";
    "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute 0 toggle";
    "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute 1 toggle";

    "${mod}+p" = "exec arandr";

    "${mod}+space" = "focus mode_toggle";
    "${mod}+Shift+space" = "floating toggle";

    "${mod}+s" = "layout stacking";
    "${mod}+w" = "layout tabbed";
    "${mod}+e" = "layout toggle split";
    "${mod}+v" = "split v";

    "${mod}+Left" = "focus left";
    "${mod}+Down" = "focus down";
    "${mod}+Up" = "focus up";
    "${mod}+Right" = "focus right";

    "${mod}+Shift+Left" = "move left";
    "${mod}+Shift+Down" = "move down";
    "${mod}+Shift+Up" = "move up";
    "${mod}+Shift+Right" = "move right";

    "${mod}+Ctrl+Shift+Left" = "resize shrink width 8 px or 8 ppt";
    "${mod}+Ctrl+Shift+Down" = "resize grow height 8 px or 8 ppt";
    "${mod}+Ctrl+Shift+Up" = "resize shrink height 8 px or 8 ppt";
    "${mod}+Ctrl+Shift+Right" = "resize grow width 8 px or 8 ppt";

    "${mod}+f" = "fullscreen toggle";
  } // workspaces);
}
