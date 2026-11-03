{
  config,
  lib,
  volumes,
  ...
}:
let
  user = config.dots.superuser.name;
in
{
  options.dots.superuser.name = lib.mkOption {
    description = "Super user name";
    type = lib.types.str;
  };
  options.dots.superuser.authorizedKeys = lib.mkOption {
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
      openssh.authorizedKeys.keys = config.dots.superuser.authorizedKeys;
    };

    preservation.preserveAt."/${volumes.persistent}".users.${user}.directories = [ "workspace" ];

    home-manager.users.${user}.imports = [ ./superuser-home.nix ];
  };
}
