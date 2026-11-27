# https://nix-darwin.github.io/nix-darwin/manual/
{ inputs, ... }:
let
  hostname = "bra-m0234";
  username = "pereiped";

  filterModules =
    moduleSet: names: builtins.filter (m: m != null) (map (n: moduleSet.${n} or null) names);

  wantedModules = [
    # own configuration
    "bra-m0234-config"

    # system configuration
    "base"
    "darwin-homebrew"
    "darwin-settings"

    # apps
    "darwin-karabiner"
  ];

  darwinModules = filterModules (inputs.self.darwinModules or { }) wantedModules;
  homeManagerModules = filterModules (inputs.self.modules.home-manager or { }) wantedModules;
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
    {
      config,
      pkgs,
      ...
    }:
    {
      networking.hostName = hostname;
      nixpkgs.hostPlatform = "aarch64-darwin";

      system.primaryUser = username;
      system.stateVersion = 7;

      environment.shells = [ pkgs.bashInteractive ];
      programs.bash.completion.enable = true;
      programs.bash.enable = true;

      users.users.${username} = {
        home = "/Users/${username}";
        shell = pkgs.bashInteractive;
      };

      fonts.packages = with pkgs; [
        nerd-fonts.code-new-roman
      ];

      homebrew.casks = [
        "alt-tab"
        "firefox"
        "google-chrome"
        "handy"
        "microsoft-outlook"
        "microsoft-teams"
        "rectangle"
        "tunnelblick"
      ];

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
        alacritty
        fzf
        git
        lazygit
        lima
        neovim
        qemu
        tmux
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
