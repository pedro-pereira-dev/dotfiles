{
  config,
  inputs,
  lib,
  pkgs,
  volumes,
  ...
}:
let
  superuser = "chuck";
  user = "tv";
  steamDeck = pkgs.makeDesktopItem {
    name = "steam";
    desktopName = "Steam";
    exec = "steam -gamepadui";
    icon = "steam";
    categories = [ "Favorites" ];
  };
  vacuumTube = pkgs.makeDesktopItem {
    name = "vacuum-tube";
    desktopName = "Vacuum Tube";
    exec = "VacuumTube";
    categories = [ "Favorites" ];
  };
in
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ./nixos-tv-hardware-configuration.nix
    ./nixos-tv-disko.nix

    ../../flakes.d/modules/system.nix
    ../../flakes.d/modules/bootloader.nix
    ../../flakes.d/modules/user.nix
    ../../flakes.d/modules/sshd.nix
  ];

  dots.system.hostName = "nixos-tv";
  dots.system.platform = "x86_64-linux";

  dots.bootloader.modules = [ "amdgpu" ];
  dots.bootloader.timeout = 0;

  preservation.enable = true;

  dots.users.${superuser} = {
    authorized_keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
    ];
    password = "/${volumes.secrets}/${superuser}";
    root = true;
  };

  dots.users.${user} = {
    authorized_keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
    ];
    groups = [
      "audio"
      "input"
      "video"
    ];
    password = "/${volumes.secrets}/${user}";
  };

  dots.sshd.enable = true;
  dots.sshd.preservation_volume = volumes.data;

  # hardware.bluetooth.enable = true;
  # hardware.bluetooth.powerOnBoot = true;
  # hardware.enableRedistributableFirmware = true;
  #
  # nixpkgs.config.allowUnfreePredicate =
  #   pkg:
  #   builtins.elem (lib.getName pkg) [
  #     "steam"
  #     "steam-unwrapped"
  #   ];
  #
  # networking.dhcpcd.wait = "background";
  # networking.wireless.iwd.enable = true;
  #
  # preservation.preserveAt."/${volumes.data}" = {
  #   directories = [
  #     "/var/lib/bluetooth"
  #   ];
  #   users.${user}.files = [
  #     ".config/plasma-bigscreen/applications-blacklistrc"
  #   ];
  # };
  #
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = user;
  # services.displayManager.defaultSession = "plasma-bigscreen-wayland";
  # services.displayManager.plasma-login-manager.enable = true;
  # services.displayManager.sessionPackages = [ pkgs.kdePackages.plasma-bigscreen ];
  #
  # services.desktopManager.plasma6.enable = true;
  #
  # programs.steam.enable = true;
  #
  # environment.systemPackages = [
  #   pkgs.kdePackages.kdeconnect-kde
  #   pkgs.kdePackages.plasma-bigscreen
  #   pkgs.kdePackages.plasma-nm
  #   pkgs.vacuum-tube
  #   (lib.hiPrio steamDeck)
  #   (lib.hiPrio vacuumTube)
  # ];
  #
  # environment.plasma6.excludePackages = with pkgs.kdePackages; [
  # ];
  #
  # fonts.packages = [ pkgs.maple-mono.NF ];
  #
  # documentation.enable = false;
  # documentation.nixos.enable = false;
  #
  # home-manager.users.${user} = {
  #   imports = [ inputs.plasma-manager.homeModules.plasma-manager ];
  #   home.stateVersion = "26.11";
  #
  #   programs.plasma.enable = true;
  #   programs.plasma.overrideConfig = true;
  #   programs.plasma.configFile = {
  #     kcminputrc.Keyboard.NumLock = 0;
  #     kcminputrc.Keyboard.RepeatDelay = 250;
  #     kcminputrc.Keyboard.RepeatRate = 100;
  #
  #     kdeglobals.General.AccentColor = "233,61,88";
  #     kdeglobals.General.LastUsedCustomAccentColor = "233,61,88";
  #     kdeglobals.General.XftAntialias = true;
  #     kdeglobals.General.XftHintStyle = "hintslight";
  #     kdeglobals.General.XftSubPixel = "none";
  #     kdeglobals.General.fixed = "Maple Mono NF,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0";
  #     kdeglobals.General.font = "Maple Mono NF,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0";
  #     kdeglobals.General.menuFont = "Maple Mono NF,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0";
  #     kdeglobals.General.smallestReadableFont = "Maple Mono NF,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0";
  #     kdeglobals.General.toolBarFont = "Maple Mono NF,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0";
  #     kdeglobals.KDE.AnimationDurationFactor = 0.5;
  #     kdeglobals.KDE.widgetStyle = "Breeze";
  #     kdeglobals.Sounds.Theme = "freedesktop";
  #     kdeglobals.WM.activeFont = "Maple Mono NF,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0";
  #
  #     kscreenlockerrc.Daemon.Autolock = false;
  #     kscreenlockerrc.Daemon.LockOnResume = false;
  #     kscreenlockerrc.Daemon.Timeout = 0;
  #
  #     kwinrc.Effect-overview.BorderActivate = 9;
  #     kwinrc.Plugins.zoomEnabled = false;
  #
  #     plasma-localerc.Translations.LANGUAGE = "en_US";
  #     plasmaparc.General.VolumeStep = 1;
  #   };
  #
  #   home.activation.bigscreenWhitelist =
  #     inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ]
  #       ''
  #             mkdir -p "$HOME/.config/plasma-bigscreen"
  #
  #         DIRS=$(for d in \
  #           /run/current-system/sw/share/applications \
  #           "$HOME/.nix-profile/share/applications" \
  #           "/etc/profiles/per-user/$USER/share/applications" \
  #           "$HOME/.local/share/applications"; do
  #           if [ -d "$d" ]; then printf '%s\n' "$d"; fi
  #         done)
  #
  #         APPS=$(${pkgs.findutils}/bin/find $DIRS \
  #           -name "*.desktop" 2>/dev/null \
  #               | ${pkgs.findutils}/bin/xargs -r -n 1 ${pkgs.coreutils}/bin/basename \
  #               | ${pkgs.gnused}/bin/sed 's/\.desktop$//' \
  #               | ${pkgs.coreutils}/bin/sort -u \
  #               | ${pkgs.coreutils}/bin/paste -sd, -)
  #
  #             printf "[Applications]\nblacklist=%s\n" "$APPS" > "$HOME/.config/plasma-bigscreen/applications-blacklistrc"
  #       '';
  # };
}
