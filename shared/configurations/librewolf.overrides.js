pref("browser.ctrlTab.sortByRecentlyUsed", true);
pref("browser.download.always_ask_before_handling_new_types", true);
pref("browser.download.autohideButton", true);
pref("browser.formfill.enable", true);
pref("browser.newtabpage.activity-stream.feeds.topsites", true);
pref("browser.newtabpage.activity-stream.showSearch", false);
pref("browser.newtabpage.activity-stream.topSitesRows", 4);
pref("browser.newtabpage.pinned", [
  { url: "https://www.messenger.com", label: "Messenger" },
  { url: "https://www.youtube.com", label: "Youtube" },
  null,
  null,
  null,
]);
pref("browser.search.separatePrivateDefault", false);
pref("browser.tabs.hoverPreview.showThumbnails", false);
pref("browser.uiCustomization.state", {
  placements: {
    "widget-overflow-fixed-list": [],
    "unified-extensions-area": [],
    "nav-bar": [
      "back-button",
      "forward-button",
      "stop-reload-button",
      "vertical-spacer",
      "urlbar-container",
      "save-to-pocket-button",
      "downloads-button",
      "fxa-toolbar-menu-button",
      "ublock0_raymondhill_net-browser-action",
      "unified-extensions-button",
      "logins-button",
      "developer-button",
    ],
    "toolbar-menubar": ["menubar-items"],
    TabsToolbar: ["tabbrowser-tabs", "new-tab-button", "alltabs-button"],
    "vertical-tabs": [],
    PersonalToolbar: ["import-button", "personal-bookmarks"],
  },
  seen: ["developer-button", "ublock0_raymondhill_net-browser-action"],
  dirtyAreaCache: [
    "nav-bar",
    "vertical-tabs",
    "PersonalToolbar",
    "toolbar-menubar",
    "TabsToolbar",
  ],
  currentVersion: 21,
  newElementCount: 3,
});
pref("browser.warnOnQuitShortcut", false);
pref("extensions.formautofill.addresses.enabled", true);
pref("extensions.formautofill.creditCards.enabled", true);
pref("general.smoothScroll", false);
pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);
pref("middlemouse.paste", false);
pref("network.dns.disableIPv6", true);
pref("signon.autofillForms", true);
pref("signon.rememberSignons", true);
