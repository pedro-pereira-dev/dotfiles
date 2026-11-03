{
  config,
  lib,
  volumes,
  ...
}:
let
  user = config.dots.super.user;
in
{
  options.dots.super.user = lib.mkOption {
    description = "Super user name";
    type = lib.types.str;
  };
  options.dots.super.authorizedKeys = lib.mkOption {
    default = [ ];
    description = "Authorized keys for super user";
    type = lib.types.listOf lib.types.str;
  };

  config = {
    users.users.root.hashedPassword = "!";
    nix.settings.trusted-users = [ user ];

    users.users.${user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialPassword = "changeme";
      hashedPasswordFile = "/${volumes.persistent}/secrets/${user}";
      openssh.authorizedKeys.keys = config.dots.super.authorizedKeys;
    };

    preservation.preserveAt."/${volumes.persistent}".users.${user}.directories = [ "workspace" ];

    home-manager.users.${user}.imports = [ ./superuser-home.nix ];
  };
}
