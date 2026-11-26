{ inputs, ... }:
let
  common =
    { config, lib, ... }:
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

        time.timeZone = "Europe/Lisbon";
      };
    };

  nixos = {
    system.stateVersion = "26.11";

    console.keyMap = "pt-latin9";
  };
in
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.nixosModules.system.imports = [
    common
    nixos
  ];
  flake.darwinModules.system.imports = [
    common
    inputs.home-manager.darwinModules.home-manager
  ];
}
