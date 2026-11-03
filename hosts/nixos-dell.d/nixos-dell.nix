{ inputs, pkgs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ./nixos-dell-hardware-configuration.nix
    ./nixos-dell-disko.nix

    ../../flakes.d/profiles/base.nix
    ../../flakes.d/users/chuck.nix
  ];

  networking.hostName = "nixos-dell";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";

  preservation.enable = true;
}
