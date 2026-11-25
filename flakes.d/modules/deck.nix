{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.dots.deck;
in
{
  options.dots.deck = {
    session = lib.mkOption {
      readOnly = true;
      type = lib.types.str;
    };
    user = lib.mkOption {
      type = lib.types.str;
    };
  };

  imports = [ inputs.deck-rs.nixosModules.default ];

  config = {
    programs.labwc.enable = true;
    programs.deck-rs.enable = true;

    dots.deck.session = "labwc";

    home-manager.users.${cfg.user} = {
      home.stateVersion = "26.11";
      xdg.configFile."labwc/autostart".text = ''
        deck-rs &
      '';
    };
  };
}
