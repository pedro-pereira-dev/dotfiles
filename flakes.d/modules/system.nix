{
  config,
  lib,
  ...
}:
{
  options.dots.system = {
    hostName = lib.mkOption {
      type = lib.types.str;
    };
    platform = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = {
    nix.settings.experimental-features = [
      "flakes"
      "nix-command"
    ];

    networking.hostName = config.dots.system.hostName;
    nixpkgs.hostPlatform = config.dots.system.platform;
    system.stateVersion = "26.11";

    console.keyMap = "pt-latin9";
    time.timeZone = "Europe/Lisbon";
  };
}
