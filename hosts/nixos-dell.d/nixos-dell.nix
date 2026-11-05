{
  inputs,
  lib,
  pkgs,
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
    ../../flakes.d/modules/power-profile.nix
    ../../flakes.d/users/superuser.nix
    ../../flakes.d/users/deckuser.nix
  ];

  networking.hostName = "nixos-dell";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";

  preservation.enable = true;

  services.xserver.xkb.layout = "pt";
  services.xserver.xkb.options = "lv3:ralt_switch";
  services.libinput.touchpad.naturalScrolling = true;
  programs.ssh.knownHosts."github.com".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  programs.gnupg.agent.enable = true;

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager.defaultSession = "plasma";
  services.displayManager.autoLogin = {
    enable = true;
    user = "chuck";
  };
  fonts.packages = [ pkgs.nerd-fonts.code-new-roman ];

  hardware.enableRedistributableFirmware = true;
  networking.networkmanager = {
    enable = true;
    # PSK is read at boot from a root-only env file (psk-flags=0 stores it in the profile)
    ensureProfiles = {
      environmentFiles = [ "/persistent/secrets/wifi.env" ];
      profiles.UFG6A41DFQ = {
        connection = {
          id = "UFG6A41DFQ";
          uuid = "fabae3e0-2500-439e-a6ed-959335dc2343";
          type = "wifi";
          autoconnect = true;
        };
        wifi = {
          mode = "infrastructure";
          ssid = "UFG6A41DFQ";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$PSK";
          psk-flags = 0;
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };
    };
  };
  systemd.tmpfiles.rules = [ "d /persistent/secrets 0700 root root -" ];
  preservation.preserveAt."/persistent".directories = [
    "/etc/NetworkManager/system-connections"
  ];

  # system-wide dark Plasma defaults; user overrides in ~/.config still win
  environment.etc."xdg/kdeglobals".text = ''
    [General]
    ColorScheme=BreezeDark

    [KDE]
    LookAndFeelPackage=org.kde.breezedark.desktop
  '';

  # Klipper: KDE clipboard history, started with the Plasma session
  environment.etc."xdg/autostart/org.kde.klipper.desktop".source =
    "${pkgs.kdePackages.plasma-workspace}/share/applications/org.kde.klipper.desktop";

  dots.superuser.name = "chuck";
  dots.superuser.authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
  ];

  dots.deckuser.name = "deck";

  environment.systemPackages = with pkgs; [
    alacritty
    firefox
    git
    gnupg
    lazygit
    neovim
    tmux
    wofi
  ];
}
