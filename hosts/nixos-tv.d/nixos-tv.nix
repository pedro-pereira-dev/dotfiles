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
    alacritty
  ];

  users.users.${user} = {
    extraGroups = [ "wheel" ];
    initialPassword = "changeme";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
    ];
  };

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  virtualisation.vmVariant.virtualisation.forwardPorts = [
    {
      from = "host";
      host.address = "127.0.0.1";
      host.port = 2222;
      guest.port = 22;
    }
  ];

  programs.labwc.enable = true;

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = user;
  services.displayManager.defaultSession = "labwc";
  services.displayManager.ly.enable = true;
}
