{ lib, pkgs, ... }:
{
  home.activation.cloneDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "$HOME/workspace/personal/dotfiles/.git" ]; then
      export PATH=${
        lib.makeBinPath [
          pkgs.curl
          pkgs.gnutar
          pkgs.gzip
        ]
      }:$PATH
      run bash -c "$(curl -fsSL https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/main/pull)" || true
    fi
  '';
}
