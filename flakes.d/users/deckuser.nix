{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  user = config.dots.deckuser.name;
in
{
  options.dots.deckuser.name = lib.mkOption {
    description = "deck-ui user name";
    type = lib.types.str;
  };

  config = {
    users.users.${user} = {
      isNormalUser = true;
    };

    programs.sway.enable = true;
    programs.sway.package = null;
    services.getty.autologinUser = user;

    home-manager.extraSpecialArgs = { inherit inputs; };
    home-manager.users.${user}.imports = [ ./deckuser-home.nix ];
  };
}
