{ config, lib, ... }:
{
  options.programs.ags-deck-ui.enable = lib.mkEnableOption "ags-deck-ui";

  config = lib.mkIf config.programs.ags-deck-ui.enable {
    programs.ags.enable = true;
    programs.ags.configDir = ../../ags-deck-ui/src;
  };
}
