{
  flake-parts-lib,
  lib,
  moduleLocation,
  self,
  ...
}:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
    ;
  inherit (flake-parts-lib)
    mkSubmoduleOptions
    ;
in
{
  config = {
    flake-file.inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";
    flake-file.inputs.darwin.url = "github:nix-darwin/nix-darwin";
  };

  options = {
    flake = mkSubmoduleOptions {
      darwinConfigurations = mkOption {
        default = { };
        type = types.lazyAttrsOf types.raw;
      };
      darwinModules = mkOption {
        apply = mapAttrs (
          k: v: {
            _class = "darwin";
            _file = "${toString moduleLocation}#darwinModules.${k}";
            imports = [ v ];
          }
        );
        default = { };
        type = types.lazyAttrsOf types.deferredModule;
      };
    };
  };
}
