{ ... }: {
  flake.modules.homeManager.bash = {
    programs.bash = {
      enable = true;
      initExtra = ''
        #!/usr/bin/env bash
        # Bash configuration (macOS / bra-m0234).
        # NOTE: the dotfiles repo no longer ships bash rc files; keep this in sync manually.

        # Prepend a directory to PATH if it exists and is not already present.
        _prepend_path() {
          if [[ -d $1 && ":$PATH:" != *":$1:"* ]]; then
            export PATH="$1:$PATH"
          fi
        }

        # Homebrew
        if [[ -x /opt/homebrew/bin/brew ]]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        _prepend_path "$HOME/.local/bin"
        _prepend_path "$HOME/.local/share/fnm"
        _prepend_path "$HOME/.luarocks/bin"
        _prepend_path "$HOME/.opencode/bin"

        if [[ $- == *i* ]]; then
          # fnm (interactive only)
          if command -v fnm >/dev/null 2>&1; then
            eval "$(fnm env --use-on-cd --shell bash)"
          fi
        fi

        unset -f _prepend_path
      '';
    };
  };
}
