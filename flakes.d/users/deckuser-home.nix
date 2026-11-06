{ config, lib, ... }:
{
  home.stateVersion = "26.11";

  programs.bash.enable = true;
  programs.bash.profileExtra = lib.mkAfter ''
    if [[ $(tty) == /dev/tty1 && $(id -un) == ${lib.escapeShellArg config.home.username} ]]; then
      exec sway
    fi
  '';
}
