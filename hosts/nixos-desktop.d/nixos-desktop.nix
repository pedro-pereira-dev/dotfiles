{ inputs, pkgs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ./nixos-desktop-disko.nix
    ./nixos-desktop-hardware-configuration.nix
    ../../flakes.d/profiles/nixos.nix
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
