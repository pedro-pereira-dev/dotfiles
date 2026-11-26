{
  flake.darwinModules.opencode-darwin =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          opencode = prev.opencode.overrideAttrs (old: {
            node_modules = old.node_modules.overrideAttrs (o: {
              buildPhase =
                pkgs.lib.throwIfNot (pkgs.lib.hasInfix "--frozen-lockfile" o.buildPhase)
                  "opencode node_modules buildPhase no longer contains --frozen-lockfile"
                  (
                    builtins.replaceStrings [ "--frozen-lockfile" ] [ "--backend=copyfile --frozen-lockfile" ]
                      o.buildPhase
                  );
            });
          });
        })
      ];
    };
}
