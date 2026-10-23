{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ./disko.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "nixos-dell";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.kernelParams = [ "quiet" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.systemd-boot.enable = true;

  users.users.root.initialPassword = "changeme";

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
}
