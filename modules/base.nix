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
    # auto generated flake.nix
    flake-file.inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # dendritic
    flake-file.inputs.flake-file.url = "github:vic/flake-file";
    flake-file.inputs.flake-parts.url = "github:hercules-ci/flake-parts";
    flake-file.inputs.import-tree.url = "github:vic/import-tree";

    # lockfile deduplication
    flake-file.inputs.flake-compat.url = "github:NixOS/flake-compat";
    flake-file.inputs.flake-utils.url = "github:numtide/flake-utils";

    systems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];

    flake-file.nixConfig = nixConfig;
    flake.nixConfig = nixConfig;

    flake.darwinModules.system.nixpkgs.config = nixpkgsConfig;
    flake.nixosModules.system.nixpkgs.config = nixpkgsConfig;
  };
}
