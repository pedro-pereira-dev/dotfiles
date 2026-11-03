{
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ./nixos-dell-hardware-configuration.nix
    ./nixos-dell-disko.nix

    ../../flakes.d/profiles/base.nix
    ../../flakes.d/users/superuser.nix
    ../../flakes.d/users/deckuser.nix
  ];

  networking.hostName = "nixos-dell";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";

  preservation.enable = true;

  dots.superuser.name = "chuck";
  dots.superuser.authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
  ];

  dots.deckuser.name = "deck";
}
