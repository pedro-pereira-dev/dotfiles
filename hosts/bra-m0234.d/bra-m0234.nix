{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ../../flakes.d/modules/dots.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "bra-m0234";
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "pereiped";
  system.stateVersion = 7;

  environment.shells = with pkgs; [ bashInteractive ];
  launchd.user.envVariables.LC_COLLATE = "C";
  programs.bash.completion.enable = true;
  programs.bash.enable = true;
  system.activationScripts.postActivation.text = ''
    bash=${pkgs.bashInteractive}/bin/bash
    user=${config.system.primaryUser}
    if ! dscl . -read "/Users/$user" UserShell | grep -qxF "UserShell: $bash"; then sudo chsh -s "$bash" "$user"; fi
  '';

  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.onActivation.extraEnv.HOMEBREW_NO_ENV_HINTS = "1";
  homebrew.onActivation.upgrade = true;

  homebrew.taps = [
    {
      name = "mattness/alacritty";
      trusted = true;
    }
  ];
  homebrew.casks = [
    "alt-tab"
    "firefox"
    "font-code-new-roman-nerd-font"
    "google-chrome"
    "handy"
    "karabiner-elements"
    "librewolf"
    "mattness/alacritty/alacritty-signed"
    "microsoft-outlook"
    "microsoft-teams"
    "rectangle"
    "stay"
    "tastytrade"
    "tunnelblick"
  ];

  environment.systemPackages = with pkgs; [
    fastfetch
    git
    lima
    qemu
  ];
}
