{
  config,
  inputs,
  lib,
  pkgs,
  volumes,
  ...
}:
let
  superuser = "chuck";
  user = "tv";
in
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ./nixos-dell-hardware-configuration.nix
    ./nixos-dell-disko.nix
  ];

  networking.hostName = "nixos-dell";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";

  preservation.enable = true;

  console.keyMap = "pt-latin9";
  time.timeZone = "Europe/Lisbon";

  boot.kernelParams = [ "quiet" ];
  hardware.enableRedistributableFirmware = true;
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;

  nix.settings.experimental-features = [
    "flakes"
    "nix-command"
  ];

  users.users.${superuser} = {
    extraGroups = [ "wheel" ];
    hashedPasswordFile = "/${volumes.secrets}/${superuser}";
    initialPassword = "changeme";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
    ];
  };

  users.users.${user} = {
    extraGroups = [
      "audio"
      "input"
      "video"
    ];
    hashedPassword = "";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
    ];
  };

  environment.systemPackages = with pkgs; [
    alacritty
    btop
    htop
    jellyfin-media-player
  ];

  services.openssh.enable = true;
  services.openssh.settings.KbdInteractiveAuthentication = false;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.PermitRootLogin = "no";

  services.openssh.hostKeys = lib.mkIf (config.preservation.enable or false) [
    {
      path = "/${volumes.data}/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = user;
  services.displayManager.defaultSession = "labwc";
  services.displayManager.ly.enable = true;

  programs.labwc.enable = true;

  environment.etc."xdg/labwc/autostart" = {
    mode = "0755";
    text = ''
      ${inputs.deck-rs.packages.${pkgs.system}.default}/bin/deck-rs &
    '';
  };

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
    ];

  preservation.preserveAt."/${volumes.data}" = {
    directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
    ];
    users.${user}.directories = [
      ".config/jellyfin.org"
      ".local/share/Steam"
      ".local/share/jellyfinmediaplayer"
      ".steam"
    ];
  };
}
