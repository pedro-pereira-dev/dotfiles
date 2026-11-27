{ inputs, ... }:
{
  flake-file.inputs.brew-src.flake = false;
  flake-file.inputs.brew-src.url = "github:homebrew/brew";
  flake-file.inputs.homebrew-cask.flake = false;
  flake-file.inputs.homebrew-cask.url = "github:homebrew/homebrew-cask";
  flake-file.inputs.homebrew-core.flake = false;
  flake-file.inputs.homebrew-core.url = "github:homebrew/homebrew-core";
  flake-file.inputs.nix-homebrew.url = "github:zhaofengli/nix-homebrew";

  flake.darwinModules.darwin-homebrew =
    { config, ... }:
    {
      imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

      nix-homebrew.enable = true;
      nix-homebrew.user = config.system.primaryUser;

      # latest homebrew version package
      nix-homebrew.package = inputs.brew-src // {
        name = "brew-${inputs.brew-src.shortRev}";
        version = inputs.brew-src.shortRev;
      };

      # homebrew custom taps
      nix-homebrew.taps."homebrew/homebrew-cask" = inputs.homebrew-cask;
      nix-homebrew.taps."homebrew/homebrew-core" = inputs.homebrew-core;
    };
}
