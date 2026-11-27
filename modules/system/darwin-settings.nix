# https://nix-darwin.github.io/nix-darwin/manual/
{
  flake.darwinModules.darwin-settings = {
    homebrew.enable = true;
    homebrew.enableBashIntegration = true;
    homebrew.greedyCasks = true;
    homebrew.onActivation.autoUpdate = true;
    homebrew.onActivation.cleanup = "zap";
    homebrew.onActivation.upgrade = true;

    security.pam.services.sudo_local.reattach = true;
    security.pam.services.sudo_local.touchIdAuth = true;

    system.defaults.NSGlobalDomain.AppleFontSmoothing = 2;
    system.defaults.NSGlobalDomain.InitialKeyRepeat = 200;
    system.defaults.NSGlobalDomain.KeyRepeat = 100;

    system.defaults.CustomUserPreferences."com.apple.desktopservices".DSDontWriteNetworkStores = true;
    system.defaults.CustomUserPreferences."com.apple.desktopservices".DSDontWriteUSBStores = true;
    system.defaults.CustomUserPreferences."com.apple.screensaver".askForPassword = 0;

    system.defaults.dock.autohide = false;
    system.defaults.dock.expose-animation-duration = 0.2;
    system.defaults.dock.launchanim = false;
    system.defaults.dock.mru-spaces = false;
    system.defaults.dock.orientation = "bottom";
    system.defaults.dock.show-process-indicators = true;
    system.defaults.dock.show-recents = false;
    system.defaults.dock.showhidden = true;
    system.defaults.dock.static-only = false;
    system.defaults.dock.tilesize = 32;

    system.defaults.CustomUserPreferences."com.apple.finder".FXDefaultSearchScope = "SCcf";
    system.defaults.CustomUserPreferences."com.apple.finder".FXInfoPanesExpanded.General = true;
    system.defaults.CustomUserPreferences."com.apple.finder".FXInfoPanesExpanded.OpenWith = true;
    system.defaults.CustomUserPreferences."com.apple.finder".FXInfoPanesExpanded.Privileges = true;
    system.defaults.CustomUserPreferences."com.apple.finder".OpenWindowForNewRemovableDisk = true;
    system.defaults.CustomUserPreferences."com.apple.finder"._FXSortFoldersFirst = true;
    system.defaults.finder.AppleShowAllExtensions = true;
    system.defaults.finder.FXEnableExtensionChangeWarning = false;
    system.defaults.finder.FXPreferredViewStyle = "Nlsv";
    system.defaults.finder.QuitMenuItem = true;
    system.defaults.finder.ShowPathbar = true;
    system.defaults.finder.ShowStatusBar = true;
    system.defaults.finder._FXShowPosixPathInTitle = true;
  };
}
