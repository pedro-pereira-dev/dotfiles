{ inputs, pkgs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ./nixos-dell-hardware-configuration.nix
    ./nixos-dell-disko.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "nixos-dell";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";

  boot.kernelParams = [ "quiet" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.systemd-boot.enable = true;

  nix.settings.trusted-users = [ "chuck" ];
  users.users.chuck.extraGroups = [ "wheel" ];
  users.users.chuck.hashedPasswordFile = "/persistent/secrets/chuck";
  users.users.chuck.initialPassword = "changeme";
  users.users.chuck.isNormalUser = true;
  users.users.chuck.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "steam"
      "mdk-sdk"
      "steam-unwrapped"
    ];
  programs.steam.enable = true;
  programs.labwc.enable = true;
  services.displayManager.ly.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "chuck";
  services.displayManager.defaultSession = "labwc";
  services.displayManager.ly.x11Support = false;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.chuck = { config, ... }: {
    imports = [
      inputs.ags-deck-ui.homeManagerModules.default
      ../../flakes.d/modules/home-clone-dotfiles.nix
    ];
    home.stateVersion = "26.11";
    home.packages = [
      pkgs.alacritty
      pkgs.delfin
      pkgs.fladder
      pkgs.jellyfin-desktop
      pkgs.jellyfin-mpv-shim
      pkgs.tsukimi
    ];
    home.file.".local/bin/dots".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/workspace/personal/dotfiles/dots";
    programs.bash.enable = true;
    programs.bash.initExtra = ''
      _prepend_path() { if [[ -d $1 && ":$PATH:" != *":$1:"* ]]; then export PATH="$1:$PATH"; fi; }
      _prepend_path "$HOME/.local/bin"
    '';
    programs.ags-deck-ui.enable = true;
    xdg.configFile."labwc/autostart".text = "ags-deck-ui &\n";
  };

  preservation.enable = true;
  preservation.preserveAt."/persistent".users.chuck.directories = [ "workspace" ];

  services.openssh.enable = true;
  services.openssh.hostKeys = [
    {
      path = "/persistent/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  environment.systemPackages = with pkgs; [
    btop
    fastfetch
    git
    htop
  ];
}
