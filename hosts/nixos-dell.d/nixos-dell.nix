{
  config,
  inputs,
  lib,
  pkgs,
  volumes,
  ...
}:
let
  user = "chuck";
  retroarch = pkgs.retroarch-bare.wrapper {
    cores = pkgs.retroarch-free.cores;
    settings = {
      savefile_directory = "/home/${user}/.local/share/retroarch/saves";
      savestate_directory = "/home/${user}/.local/share/retroarch/states";
    };
  };
in
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    inputs.deck-rs.nixosModules.default

    ./nixos-dell-hardware-configuration.nix
    ./nixos-dell-disko.nix
  ];

  nix.settings.experimental-features = [
    "flakes"
    "nix-command"
  ];

  networking.hostName = "nixos-dell";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";

  console.keyMap = "pt-latin9";
  time.timeZone = "Europe/Lisbon";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  preservation.enable = true;
  preservation.preserveAt."/${volumes.data}" = {
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/iwd"
    ];
    users.${user}.directories = [
      ".config/deck-rs"
      ".config/dconf"
      ".config/retroarch"
      ".config/Stremio"
      ".config/VacuumTube"
      ".local/share/retroarch"
      ".local/share/stremio"
      ".local/share/Steam"
      ".steam"
    ];
  };

  boot.consoleLogLevel = 3;
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "quiet" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;

  networking.dhcpcd.wait = "background";
  networking.wireless.iwd.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    alsa.enable = true;
    alsa.support32Bit = true;
    enable = true;
    pulse.enable = true;
  };

  users.users.${user} = {
    extraGroups = [
      "audio"
      "input"
      "video"
      "wheel"
    ];
    hashedPasswordFile = "/${volumes.secrets}/${user}";
    initialPassword = "changeme";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
    ];
  };

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = user;
  services.displayManager.defaultSession = "labwc";
  services.displayManager.ly.enable = true;

  services.fwupd.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.hostKeys = lib.mkIf (config.preservation.enable or false) [
    {
      path = "/${volumes.data}/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  programs.labwc.enable = true;
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings."com/stremio/stremio" = {
          "remember-window-state" = true;
          "window-fullscreen" = true;
          "window-maximized" = false;
        };
      }
    ];
  };
  programs.deck-rs = {
    enable = true;
    settings = {
      app = [
        {
          category = "games";
          command = [
            "steam"
            "-gamepadui"
          ];
          env.GDK_BACKEND = "wayland,x11";
          icon = "󰓓";
          name = "steam";
        }
        {
          category = "games";
          command = [
            "retroarch"
            "--fullscreen"
          ];
          icon = "󰊗";
          name = "retroarch";
        }
        {
          category = "media";
          command = [
            "VacuumTube"
            "--fullscreen"
          ];
          icon = "󰾎";
          name = "vacuum-tube";
        }
        {
          category = "media";
          command = [
            "stremio"
            "--no-window-decorations"
          ];
          icon = "󰐊";
          name = "stremio";
        }
      ];
      network.backend = "iwd";
      ui = {
        favorites = [
          "steam"
          "retroarch"
          "vacuum-tube"
          "stremio"
        ];
        font = "${pkgs.maple-mono.NF}/share/fonts/truetype/NerdFonts/MapleMonoNerdFont-Regular.ttf";
        font_family = "Maple Mono NF";
        icons = {
          games = "󰊗";
          media = "󰒋";
        };
        modules = [
          "home"
          "favorites"
          "games"
          "media"
          "settings"
          "power"
        ];
      };
    };
  };
  environment.etc."xdg/labwc/autostart" = {
    mode = "0755";
    text = ''
      ${config.programs.deck-rs.package}/bin/deck-rs &
    '';
  };

  programs.steam.enable = true;
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "stremio-linux-shell"
      "steam"
      "steam-unwrapped"
    ];

  environment.systemPackages = with pkgs; [
    btop
    fastfetch
    htop
    iwd
    jellyfin-desktop
    powertop
    retroarch
    stremio-linux-shell
    vacuum-tube
  ];

  fonts.packages = [ pkgs.maple-mono.NF ];
}
