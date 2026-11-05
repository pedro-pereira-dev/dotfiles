{ inputs, pkgs, ... }:
let
  user = "tv";
in
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "nixos-tv";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";

  console.keyMap = "pt-latin9";
  time.timeZone = "Europe/Lisbon";

  environment.systemPackages = with pkgs; [
    fastfetch
  ];

  users.users.${user} = {
    extraGroups = [ "wheel" ];
    initialPassword = "changeme";
    isNormalUser = true;
  };

  programs.labwc.enable = true;

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = user;
  services.displayManager.defaultSession = "labwc";
  services.displayManager.ly.enable = true;
}
