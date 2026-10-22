{ inputs, pkgs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ./disko.nix
    ./hardware-configuration.nix
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
  networking.hostName = "nixos-desktop";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  services.lact.enable = true;
  services.fwupd.enable = true;

  environment.systemPackages = [
    pkgs.btop
    pkgs.fastfetch
    pkgs.htop
    pkgs.radeontop
    pkgs.vulkan-tools
  ];
}
