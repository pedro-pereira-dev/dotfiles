{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ./nixos-dell-hardware-configuration.nix
    ./nixos-dell-disko.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "nixos-dell";

  boot.kernelParams = [ "quiet" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.systemd-boot.enable = true;

  users.users.root.initialPassword = "changeme";

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  users.users.chuck.isNormalUser = true;
  users.users.chuck.extraGroups = [ "wheel" ];
  nix.settings.trusted-users = [ "chuck" ];

  users.users.chuck.hashedPasswordFile = "/persistent/secrets/chuck";
  users.users.chuck.initialPassword = "changeme";

  users.users.chuck.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
  ];
}
