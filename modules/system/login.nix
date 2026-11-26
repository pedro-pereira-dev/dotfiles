{
  flake.nixosModules.login =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.dots.login;
    in
    {
      options.dots.login = {
        autologin = {
          user = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
          session = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
        };
      };

      config = {
        services.displayManager.ly.enable = true;

        services.displayManager.defaultSession = lib.mkIf (
          cfg.autologin.session != null
        ) cfg.autologin.session;

        services.displayManager.autoLogin = lib.mkIf (cfg.autologin.user != null) {
          enable = true;
          user = cfg.autologin.user;
        };
      };
    };
}
