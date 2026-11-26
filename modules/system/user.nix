{
  flake.nixosModules.user =
    {
      config,
      lib,
      ...
    }:
    {
      options.dots.users = lib.mkOption {
        default = { };
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              authorized_keys = lib.mkOption {
                default = [ ];
                type = lib.types.listOf lib.types.str;
              };
              groups = lib.mkOption {
                default = [ ];
                type = lib.types.listOf lib.types.str;
              };
              password = lib.mkOption {
                default = null;
                type = lib.types.nullOr lib.types.str;
              };
              root = lib.mkOption {
                default = false;
                type = lib.types.bool;
              };
              service = lib.mkOption {
                default = false;
                type = lib.types.bool;
              };
            };
          }
        );
      };

      config = {
        assertions = lib.mapAttrsToList (username: cfg: {
          assertion = !(cfg.service && cfg.root);
          message = "dots.users.${username}: service and root are mutually exclusive";
        }) config.dots.users;

        users.users = lib.mapAttrs (username: cfg: {
          extraGroups = lib.unique (cfg.groups ++ lib.optional cfg.root "wheel");
          hashedPasswordFile = cfg.password;
          initialPassword = "changeme";
          isNormalUser = !cfg.service;
          isSystemUser = cfg.service;
          openssh.authorizedKeys.keys = cfg.authorized_keys;
        }) config.dots.users;
      };
    };
}
