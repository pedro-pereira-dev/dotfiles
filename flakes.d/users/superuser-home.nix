{ config, ... }:
{
  home.stateVersion = "26.11";

  programs.bash.enable = true;

  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  home.file.".local/bin/dots".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/workspace/personal/dotfiles/dots";
}
