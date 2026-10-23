{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ./disko.nix
    ../../flakes.d/profiles/nixos-laptop.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "nixos-dell";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.fwupd.enable = true;
}
