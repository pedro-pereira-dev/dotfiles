{ config, lib, ... }:
{
  home.stateVersion = "26.11";

  imports = [ ../modules/deck-ui.nix ];

  programs.bash.enable = true;
  programs.bash.profileExtra = lib.mkAfter ''
    if [[ $(tty) == /dev/tty1 && $(id -un) == ${lib.escapeShellArg config.home.username} ]]; then
      exec sway
    fi
  '';

  programs.deck-ui.enable = true;
}
