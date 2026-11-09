{ config, lib, inputs, pkgs, volumes, ... }:
let
  user = "chuck";
in
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ./nixos-desktop-hardware-configuration.nix
    ./nixos-desktop-disko.nix
  ];

  networking.hostName = "nixos-desktop";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";

  preservation.enable = true;

  console.keyMap = "pt-latin9";
  time.timeZone = "Europe/Lisbon";

  users.users.${user} = {
    extraGroups = [ "wheel" ];
    hashedPasswordFile = "/${volumes.secrets}/${user}";
    initialPassword = "changeme";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ 
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
    ];
  };

  environment.systemPackages = with pkgs; [
    alacritty
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

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = user;
  services.displayManager.defaultSession = "labwc";
  services.displayManager.ly.enable = true;

  programs.chromium.enable = true;
  programs.labwc.enable = true;
}
