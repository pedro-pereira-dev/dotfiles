{ inputs, ... }:
let
  hostname = "bra-m0234";
  username = "pereiped";

  filterModules =
    moduleSet: names: builtins.filter (m: m != null) (map (n: moduleSet.${n} or null) names);

  wantedModules = [
    # own configuration
    "bra-m0234-config"
  ];

  darwinModules = filterModules inputs.self.darwinModules wantedModules;
  homeManagerModules = filterModules inputs.self.modules.home-manager wantedModules;
in
{
  # adds home manager
  flake-file.inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  flake-file.inputs.home-manager.url = "github:nix-community/home-manager";

  # imports home manager
  flake.darwinConfigurations.${hostname} = inputs.darwin.lib.darwinSystem {
    modules = [ inputs.home-manager.darwinModules.home-manager ] ++ darwinModules;
  };

  # configures system
  flake.darwinModules.bra-m0234-config =
    { config, pkgs, ... }:
    {
      networking.hostName = hostname;
      nixpkgs.hostPlatform = "aarch64-darwin";

      system.primaryUser = username;
      system.stateVersion = 7;

      users.users.${username} = {
        home = "/Users/${username}";
        shell = pkgs.bash;
      };

      # wip
      # environment.systemPath = [
      #   "/run/current-system/sw/bin"
      #   "/opt/homebrew/bin"
      #   "/opt/homebrew/sbin"
      # ];
      # home-manager.useGlobalPkgs = true;
      # home-manager.useUserPackages = true;

      # home-manager.users.${username} = {
      #   imports = homeMods;
      #   home.username = username;
      #   home.homeDirectory = "/Users/${username}";
      #   home.stateVersion = "20.09";
      #   targets.darwin.copyApps.enable = true;
      #   targets.darwin.linkApps.enable = false;
      # };

      # wip

      environment.systemPackages = with pkgs; [
        fastfetch
        fzf
        git
        lazygit
        lima
        neovim
        qemu
        tmux
        zoxide
      ];

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
        "mattness/alacritty/alacritty-signed"
        "microsoft-outlook"
        "microsoft-teams"
        "rectangle"
        "stay"
        "tastytrade"
        "tunnelblick"
      ];

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users.${username} = {
        imports = homeManagerModules;
        home.stateVersion = "25.11";
        targets.darwin.copyApps.enable = true;
        targets.darwin.linkApps.enable = false;
      };
    };
}
