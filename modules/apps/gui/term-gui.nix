{ ... }: {
  flake.modules.homeManager.term-gui = {
    programs.alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";
        window = {
          padding = {
            x = 8;
            y = 4;
          };
          dynamic_padding = true;
          option_as_alt = "OnlyLeft";
        };
        font = {
          size = 14;
          normal.family = "CodeNewRoman Nerd Font Mono";
        };
        colors = {
          primary = {
            foreground = "#d2d1e6";
            background = "#000000";
          };
          normal = {
            black = "#2e3440";
            red = "#ff3242";
            green = "#44bc44";
            yellow = "#ff9400";
            blue = "#0883ff";
            magenta = "#d930d9";
            cyan = "#00d8eb";
            white = "#d8dee9";
          };
          bright = {
            black = "#4c566a";
            red = "#ff6e6e";
            green = "#9ec875";
            yellow = "#ffaf00";
            blue = "#47bfe6";
            magenta = "#d294ff";
            cyan = "#8ae2f0";
            white = "#eceff4";
          };
        };
        selection.save_to_clipboard = true;
        cursor = {
          style.blinking = "Always";
          blink_interval = 250;
          blink_timeout = 0;
        };
        keyboard.bindings =
          let
            ctrl_shift = key: action: {
              inherit key action;
              mods = "Control|Shift";
            };
          in
          [
            (ctrl_shift "0" "ResetFontSize")
            (ctrl_shift "=" "ResetFontSize")
            (ctrl_shift "_" "DecreaseFontSize")
            (ctrl_shift "-" "DecreaseFontSize")
            (ctrl_shift "*" "IncreaseFontSize")
            (ctrl_shift "+" "IncreaseFontSize")
            (ctrl_shift "C" "Copy")
            (ctrl_shift "V" "Paste")
            (ctrl_shift "PageUp" "ScrollPageUp")
            (ctrl_shift "PageDown" "ScrollPageDown")
            {
              key = "Back";
              mods = "Control";
              chars = builtins.fromJSON ''"\u0017"'';
            }
            {
              key = "Delete";
              mods = "Control";
              chars = builtins.fromJSON ''"\u001bd"'';
            }
            {
              key = "Left";
              mods = "Control";
              chars = builtins.fromJSON ''"\u001bb"'';
            }
            {
              key = "Right";
              mods = "Control";
              chars = builtins.fromJSON ''"\u001bf"'';
            }
            {
              key = "F";
              mods = "Control|Shift";
              mode = "~Search";
              action = "SearchBackward";
            }
            {
              key = "F";
              mods = "Control|Shift";
              mode = "Search";
              action = "SearchFocusNext";
            }
            {
              key = "Escape";
              mode = "Search|~Vi";
              action = "ToggleViMode";
            }
            {
              key = "Escape";
              mode = "Search";
              action = "SearchConfirm";
            }
          ];
        mouse.bindings = [
          {
            mouse = "Right";
            action = "Paste";
          }
        ];
      };
    };
  };
}
