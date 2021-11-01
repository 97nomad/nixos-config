{ lib, ... }:
rec {
  modifier = "Mod4";
  modes = {};

  window = {
    border = 1;
    hideEdgeBorders = "both";
    commands = [
      # Force use border on all windows
      { command = "border pixel 1"; criteria = { title = ".*"; }; }
    ];
  };

  output = {
    "*" = {
        bg = "/usr/share/wallpaper.png fill";
      };
  };

  startup =
    let
      lock = "swaylock -i /usr/share/wallpaper.png -s fill -F";
    in
    [
      { command = "mako"; }
      {
        command = ''
          swayidle \
            lock          '${lock}' \
            timeout   300 '${lock}' \
            resume 'swaymsg "output * dpms on"' \
            before-sleep  '${lock}'
        '';
      }
    ];

  input = {
    "*" = {
      scroll_method = "on_button_down";
      natural_scroll = "enabled";
      tap = "enabled";
      middle_emulation = "enabled";
      xkb_layout = "us,ru";
      xkb_options = "ctrl:nocaps,grp:toggle,grp_led:caps";
    };
  };

  ## template = { border = "#"; background = "#"; text = "#"; indicator = "#"; childBorder = "#"; };
  ## Colors from https://github.com/unix121/i3wm-themer/blob/master/themes/001.yml
  colors = {
    background ="#1E272B";

    focused =         { border = "#EAD49B"; background = "#1E272B"; text = "#EAD49B"; indicator = "#9D6A47"; childBorder = "#9D6A47"; };
    unfocused =       { border = "#EAD49B"; background = "#1E272B"; text = "#EAD49B"; indicator = "#78824B"; childBorder = "#78824B"; };
    focusedInactive = { border = "#EAD49B"; background = "#1E272B"; text = "#EAD49B"; indicator = "#78824B"; childBorder = "#78824B"; };
    urgent =          { border = "#EAD49B"; background = "#1E272B"; text = "#EAD49B"; indicator = "#78824B"; childBorder = "#78824B"; };
    placeholder =     { border = "#EAD49B"; background = "#1E272B"; text = "#EAD49B"; indicator = "#78824B"; childBorder = "#78824B"; };
  };

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
    "${mod}+Return" = "exec DRI_PRIME=1 alacritty";
    "${mod}+Shift+Return" = "exec ee";
    "${mod}+d" = "exec rofi -combi-mode drun#run -show combi";
    "${mod}+q" = "exec rofi-pass";
    "${mod}+Escape" = "exec loginctl lock-session";
    "${mod}+Shift+e" = "exec swaynag -t warning -m 'Do you want to exit sway?' -b 'Yes' 'swaymsg exit'";
    "Print" = "exec flameshot gui";
#    "Print" = "exec grim -g \"$(slurp)\" - | wl-copy";

    "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%";
    "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%";
    "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
    "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";

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

    "${mod}+Shift+plus" = "gaps inner current plus 6";
    "${mod}+Shift+minus" = "gaps inner current minus 6";

    "${mod}+f" = "fullscreen toggle";
  } // workspaces);

  bars = [
    { command = "waybar"; }
  ];
}
