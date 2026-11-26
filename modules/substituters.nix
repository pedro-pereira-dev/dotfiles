_: let
  substituters = [
    {
      url = "https://cache.nixos.org";
      publicKey = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
      priority = 1;
    }
    # {
    #   url = "https://example.cachix.org";
    #   publicKey = "example";
    #   priority = 2;
    # }
    {
      url = "https://nix-community.cachix.org";
      publicKey = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
      priority = 3;
    }
  ];

  nixConfig.extra-substituters = map (def: "${def.url}?priority=${toString def.priority}") substituters;
  nixConfig.extra-trusted-public-keys = builtins.catAttrs "publicKey" substituters;
in {
  flake-file.nixConfig = nixConfig;
  flake.nixConfig = nixConfig;
}
