{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ./disko.nix
    ./hardware-configuration.nix
    ../../modules/bluetooth.nix
    ../../modules/bootloader.nix
    ../../modules/code.nix
    ../../modules/display-manager-ly.nix
    ../../modules/dots.nix
    ../../modules/librewolf.nix
    ../../modules/locale.nix
    ../../modules/preservation.nix
    ../../modules/sshd.nix
    ../../modules/user-chuck.nix
    ../../modules/window-manager-labwc.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "nixos-dell";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.fwupd.enable = true;
}
