{ inputs, pkgs, ... }:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ../../flakes.d/modules/dots.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "bra-m0234";
  nix.enable = false;
  system.primaryUser = "pereiped";
  system.stateVersion = 6;
  security.pam.services.sudo_local.touchIdAuth = true;

  users.users.pereiped = {
    home = "/Users/pereiped";
    shell = pkgs.bashInteractive;
  };
  environment.shells = [ pkgs.bashInteractive ];

  environment.systemPackages = [
    pkgs.bashInteractive
    pkgs.fastfetch
    pkgs.git
    pkgs.sketchybar
  ];

  homebrew = {
    enable = true;
    taps = [
      "deskflow/tap"
      "pedro-pereira-dev/custom"
    ];
    casks = [
      "alt-tab"
      "deskflow/tap/deskflow"
      "firefox"
      "font-code-new-roman-nerd-font"
      "google-chrome"
      "handy"
      "karabiner-elements"
      "librewolf"
      "microsoft-outlook"
      "microsoft-teams"
      "pedro-pereira-dev/custom/alacritty"
      "rectangle"
      "stay"
      "tastytrade"
      "tunnelblick"
    ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.pereiped = {
    home.stateVersion = "25.05";
    home.file.".bashrc".source = ../../flakes.d/modules/home/bashrc.sh;
    home.file.".bash_profile".source = ../../flakes.d/modules/home/bash_profile.sh;
    home.file.".local/bin/update".source = ../../bin/update;
    home.file.".local/bin/maintain-macos".source = ../../bin/maintain-macos;
    home.file.".local/bin/maintain-homebrew".source = ../../bin/maintain-homebrew;
    home.file.".librewolf/librewolf.overrides.cfg".text = ''
      pref("browser.tabs.inTitlebar", 0);
    '';
    xdg.configFile."alacritty/alacritty.toml".source = ../../flakes.d/modules/home/alacritty.toml;
    xdg.configFile."borders/bordersrc".source = ./files/bordersrc;
    xdg.configFile."karabiner/karabiner.json".source = ./files/karabiner.json;
    xdg.configFile."sketchybar".source = ./files/sketchybar;
  };
}
