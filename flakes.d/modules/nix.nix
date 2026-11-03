{ lib, ... }:
{
  # nix.gc = {
  #   automatic = true;
  #   dates = "daily";
  #   options = "--delete-older-than 14d";
  #   persistent = true;
  # };
  #
  # nix.optimise = {
  #   automatic = true;
  #   dates = [ "daily" ];
  # };

  nix.settings.experimental-features = lib.mkDefault [
    "nix-command"
    "flakes"
  ];
}
