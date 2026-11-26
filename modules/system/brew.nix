{
  flake.darwinModules.brew = {
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        cleanup = "zap";
        extraEnv.HOMEBREW_NO_ENV_HINTS = "1";
        upgrade = true;
      };
      taps = [
        {
          name = "mattness/alacritty";
          trusted = true;
        }
      ];
      casks = [
        "alt-tab"
        "firefox"
        "font-code-new-roman-nerd-font"
        "google-chrome"
        "handy"
        "karabiner-elements"
        "mattness/alacritty/alacritty-signed"
        "microsoft-outlook"
        "microsoft-teams"
        "rectangle"
        "stay"
        "tastytrade"
        "tunnelblick"
      ];
    };
  };
}
