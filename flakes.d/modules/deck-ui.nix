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
      ags bundle app.tsx $out/bin/deck-ui \
        --gtk 4 -d "SRC='$src'"
    '';
  };
in
{
  options.programs.deck-ui.enable = lib.mkEnableOption "Deck UI";
  config = lib.mkIf config.programs.deck-ui.enable {
    home.packages = [ package ];
    wayland.windowManager.sway.enable = true;
    wayland.windowManager.sway.config.startup = [
      {
        command = "${package}/bin/deck-ui";
        always = true;
      }
    ];
  };
}
