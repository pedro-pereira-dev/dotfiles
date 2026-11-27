{
  inputs,
  lib,
  ...
}:
let
  nixpkgsConfig.allowUnfree = true;
  nixConfig.extra-experimental-features = "flakes nix-command pipe-operators";
in
{
  # mergeable nixconfig in modules
  options.flake.nixConfig = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = { };
  };

  imports = [
    inputs.flake-file.flakeModules.dendritic
    inputs.flake-parts.flakeModules.flakeModules
  ];

  config = {
    # nixpkgs channel
    flake-file.inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # dendritic
    flake-file.inputs.flake-file.url = "github:denful/flake-file";
    flake-file.inputs.flake-parts.url = "github:hercules-ci/flake-parts";
    flake-file.inputs.import-tree.url = "github:denful/import-tree";

    # lockfile deduplication
    # flake-file.inputs.flake-compat.url = "github:nixos/flake-compat";
    # flake-file.inputs.flake-utils.url = "github:numtide/flake-utils";

    systems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];

    flake-file.nixConfig = nixConfig;
    flake.nixConfig = nixConfig;

    flake.darwinModules.base.nixpkgs.config = nixpkgsConfig;
    flake.nixosModules.base.nixpkgs.config = nixpkgsConfig;
  };
}
