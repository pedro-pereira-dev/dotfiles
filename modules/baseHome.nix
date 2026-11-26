{ lib, ... }:
{
  options.flake.modules = lib.mkOption {
    default = { };
    type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
  };
}
