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

    ./nixos-tv-hardware-configuration.nix
    ./nixos-tv-disko.nix
  ];

  nix.settings.experimental-features = [
    "flakes"
    "nix-command"
  ];

  networking.hostName = "nixos-tv";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";

  console.keyMap = "pt-latin9";
  time.timeZone = "Europe/Lisbon";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.enableRedistributableFirmware = true;

  preservation.enable = true;
  preservation.preserveAt."/${volumes.data}" = {
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/iwd"
    ];
    users.${user}.directories = [ ".config/VacuumTube" ];
  };

  boot.consoleLogLevel = 3;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "quiet" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;

  networking.dhcpcd.wait = "background";
  networking.wireless.iwd.enable = true;

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
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
    ];
  };

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = user;
  services.displayManager.defaultSession = "labwc";
  services.displayManager.ly.enable = true;

  services.fwupd.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.hostKeys = lib.mkIf (config.preservation.enable or false) [
    {
      path = "/${volumes.data}/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  programs.labwc.enable = true;
  environment.etc."xdg/labwc/autostart" = {
    mode = "0755";
    text = ''
      ${inputs.deck-rs.packages.${pkgs.system}.default}/bin/deck-rs &
    '';
  };

  programs.steam.enable = true;
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
    ];

  environment.systemPackages = with pkgs; [
    btop
    fastfetch
    htop
    iwd
    jellyfin-desktop
    powertop
    vacuum-tube
  ];
}
