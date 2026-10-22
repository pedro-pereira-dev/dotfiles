{ pkgs, ... }: {
  environment.systemPackages = [
    (pkgs.librewolf.override {
      extraPrefsFiles = pkgs.librewolf-unwrapped.extraPrefsFiles ++ [
        (pkgs.writeText "librewolf-system-titlebar.js" ''
          pref("browser.tabs.inTitlebar", 0);
          pref("privacy.resistFingerprinting", false);
          pref("ui.systemUsesDarkTheme", 1);
          pref("layout.css.prefers-color-scheme.content-override", 0);
          pref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");
        '')
      ];
      # Sites exempt from LibreWolf's clear-cookies-on-exit; edit as needed.
      extraPolicies.Cookies.Allow = [
        "https://github.com"
        "https://atlassian.net"
        "https://google.com"
      ];
      extraPolicies.ExtensionSettings."uBlock0@raymondhill.net" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        installation_mode = "force_installed";
      };
    })
  ];
}
