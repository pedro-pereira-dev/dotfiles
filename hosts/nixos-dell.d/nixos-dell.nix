{ inputs, pkgs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ./nixos-dell-hardware-configuration.nix
    ./nixos-dell-disko.nix

    ../../flakes.d/modules/bootloader.nix
    ../../flakes.d/modules/nixos-common.nix
    ../../flakes.d/users/chuck.nix
  ];

  networking.hostName = "nixos-dell";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "steam"
      "mdk-sdk"
      "steam-unwrapped"
    ];
  programs.steam.enable = true;
  preservation.enable = true;
  programs.labwc.enable = true;
  services.displayManager.ly.enable = true;

  services.openssh.enable = true;
  services.openssh.hostKeys = [
    {
      path = "/persistent/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  environment.systemPackages = with pkgs; [
    btop
    fastfetch
    git
    htop
  ];
}
