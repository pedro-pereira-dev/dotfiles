{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  hostSystem = pkgs.stdenv.hostPlatform.system;
  ags = inputs.ags;
  package = pkgs.stdenv.mkDerivation {
    pname = "ags-deck-ui";
    version = "0.1.0";
    src = ../../dotfiles.d/ags-deck-ui;
    nativeBuildInputs = with pkgs; [
      wrapGAppsHook3
      gobject-introspection
      ags.packages.${hostSystem}.default
    ];
    buildInputs = with pkgs; [
      glib
      gtk4
      gtk4-layer-shell
      ags.packages.${hostSystem}.io
      ags.packages.${hostSystem}.astal4
    ];
    installPhase = ''
      mkdir -p $out/bin
      ags bundle app.tsx $out/bin/ags-deck-ui \
        --gtk 4 -d "SRC='$src'"
    '';
  };
in
{
  options.programs.ags-deck-ui.enable = lib.mkEnableOption "ags-deck-ui";
  config = lib.mkIf config.programs.ags-deck-ui.enable {
    home.packages = [ package ];
  };
}
