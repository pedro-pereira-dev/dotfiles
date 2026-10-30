{ inputs, pkgs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ./nixos-dell-hardware-configuration.nix
    ./nixos-dell-disko.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "nixos-dell";

  boot.kernelParams = [ "quiet" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.systemd-boot.enable = true;

  nix.settings.trusted-users = [ "chuck" ];
  users.users.chuck.extraGroups = [ "wheel" ];
  users.users.chuck.hashedPasswordFile = "/persistent/secrets/chuck";
  users.users.chuck.initialPassword = "changeme";
  users.users.chuck.isNormalUser = true;
  users.users.chuck.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
  ];

  system.stateVersion = "26.11";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.chuck = {
    imports = [ ../../flakes.d/modules/home-clone-dotfiles.nix ];
    home.stateVersion = "26.11";
  };

  preservation.enable = true;
  preservation.preserveAt."/persistent".users.chuck.directories = [ "workspace" ];

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
