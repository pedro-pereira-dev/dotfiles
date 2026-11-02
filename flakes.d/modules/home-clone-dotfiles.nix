{ lib, pkgs, ... }:
{
  home.activation.cloneDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "$HOME/workspace/personal/dotfiles/.git" ]; then
      export PATH=${lib.makeBinPath [ pkgs.git ]}:$PATH
      mkdir -p "$HOME/workspace/personal"
      git clone --branch main https://github.com/pedro-pereira-dev/dotfiles.git "$HOME/workspace/personal/dotfiles"
    fi
  '';
}
