{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ags.url = "github:aylur/ags";
    ags.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, ags, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f system nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAll (
        system: pkgs: {
          default = pkgs.stdenv.mkDerivation {
            pname = "ags-deck-ui";
            version = "0.1.0";
            src = ./src;
            nativeBuildInputs = with pkgs; [
              wrapGAppsHook3
              gobject-introspection
              ags.packages.${system}.default
            ];
            buildInputs = with pkgs; [
              glib
              gtk4
              gtk4-layer-shell
              ags.packages.${system}.io
              ags.packages.${system}.astal4
            ];
            installPhase = ''
              mkdir -p $out/bin
              ags bundle app.tsx $out/bin/ags-deck-ui \
                --gtk 4 -d "SRC='$src'"
            '';
          };
        }
      );

      homeManagerModules.default =
        { config, lib, pkgs, ... }:
        {
          options.programs.ags-deck-ui.enable = lib.mkEnableOption "ags-deck-ui";
          config = lib.mkIf config.programs.ags-deck-ui.enable {
            home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.default ];
          };
        };

      devShells = forAll (
        system: pkgs: {
          default = pkgs.mkShell {
            packages = [
              ags.packages.${system}.agsFull
              pkgs.nodejs
            ];
          };
        }
      );

      formatter = forAll (_: pkgs: pkgs.nixfmt);
    };
}
