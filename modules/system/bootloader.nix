{
  flake.nixosModules.bootloader =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dots.bootloader = {
        extraCmdline = lib.mkOption {
          default = [ ];
          type = lib.types.listOf lib.types.str;
        };
        modules = lib.mkOption {
          default = [ ];
          type = lib.types.listOf lib.types.str;
        };
        timeout = lib.mkOption {
          default = 1;
          type = lib.types.int;
        };
      };

      config = {
        boot.consoleLogLevel = 3;
        boot.initrd.kernelModules = config.dots.bootloader.modules;
        boot.kernelPackages = pkgs.linuxPackages_latest;
        boot.kernelParams = [ "quiet" ] ++ config.dots.bootloader.extraCmdline;
        boot.loader.efi.canTouchEfiVariables = true;
        boot.loader.systemd-boot.configurationLimit = 4;
        boot.loader.systemd-boot.enable = true;
        boot.loader.timeout = config.dots.bootloader.timeout;
      };
    };
}
