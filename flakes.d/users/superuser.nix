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
    security.sudo.wheelNeedsPassword = false;

    users.users.${user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialPassword = "changeme";
      hashedPasswordFile = "/${volumes.persistent}/secrets/${user}";
      openssh.authorizedKeys.keys = config.dots.superuser.authorizedKeys;
    };

    preservation.preserveAt."/${volumes.persistent}".users.${user} = {
      directories = [
        "workspace"
        {
          directory = ".mozilla";
          mode = "0755";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".gnupg";
          mode = "0700";
        }
        ".config"
        ".config/opencode"
        ".local/share/opencode"
        ".local/state/opencode"
        ".cache/opencode"
        ".luarocks"
        ".local/share/fnm"
      ];
    };

    home-manager.users.${user}.imports = [
      ./superuser-home.nix
      ./superuser-neovim.nix
    ];
  };
}
