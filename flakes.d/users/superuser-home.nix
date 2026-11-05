{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.stateVersion = "26.11";

  programs.bash.enable = true;
  programs.bash.initExtra = ''
    _prepend_path() { if [[ -d $1 && ":$PATH:" != *":$1:"* ]]; then export PATH="$1:$PATH"; fi; }
    _prepend_path /opt/homebrew/sbin
    _prepend_path /opt/homebrew/bin
    _prepend_path "$HOME/.local/bin"
    _prepend_path "$HOME/.luarocks/bin"

    # fnm
    _prepend_path "$HOME/.local/share/fnm"
    if command -v fnm >/dev/null; then
      eval "$(fnm env --use-on-cd --shell bash)"
    fi

    # opencode
    _prepend_path "$HOME/.opencode/bin"

    unset -f _prepend_path
  '';

  home.packages = with pkgs; [
    fnm
    fzf
    git
    lazygit
    luarocks
    opencode
    ripgrep
    tmux
    zoxide
  ];

  programs.firefox.enable = true;
  home.file.".gitconfig".text = ''
    [url "ssh://git@github.com/"]
      pushInsteadOf = https://github.com/

    [commit]
      gpgsign = true
    [push]
      autoSetupRemote = true
      default = current

    [user]
      name = "Pedro Pereira"
    [include]
      path = ~/.gitconfig.default
    [includeIf "gitdir:~/workspace/work/"]
      path = ~/.gitconfig.mercedes
  '';

  programs.tmux.enable = true;
  programs.tmux.terminal = "tmux-256color";
  programs.tmux.extraConfig = builtins.readFile ../../hosts/nixos-dell.d/dotfiles/tmux.conf;

  home.sessionVariables = {
    EDITOR = "nvim-reloadable";
    VISUAL = "nvim-reloadable";
  };

  home.file.".local/bin/code" = {
    source = ../../hosts/nixos-dell.d/dotfiles/code;
    executable = true;
  };
  home.file.".local/bin/nvim-reloadable" = {
    source = ../../hosts/nixos-dell.d/dotfiles/nvim-reloadable;
    executable = true;
  };
  home.file.".config/alacritty/alacritty.toml".source =
    ../../hosts/nixos-dell.d/dotfiles/alacritty.toml;
  home.file.".gitconfig.default".text = ''
    [user]
        email = "11753516+pedro-pereira-dev@users.noreply.github.com"
        signingkey = "B1B18907C404F134"
  '';
  home.file.".gitconfig.mercedes".text = ''
    [user]
        email = "pedro.pereira@mercedes-benz.com"
        signingkey = "23440B98CDDDA9F3"
  '';

  # Meta+Up maximizes the focused KWin window (keeps the default Meta+PgUp too)
  home.activation.kwinMaximizeShortcut = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /run/current-system/sw/bin/kwriteconfig6 --file kglobalshortcutsrc --group kwin \
      --key "Window Maximize" "Meta+Up,Meta+PgUp,Maximize Window"
    run /run/current-system/sw/bin/kwriteconfig6 --file kglobalshortcutsrc --group services --group Alacritty.desktop \
      --key _launch "Meta+Return,none,Alacritty"
    run /run/current-system/sw/bin/kwriteconfig6 --file kglobalshortcutsrc --group services --group org.kde.plasma.kickoff.desktop \
      --key _launch "none,Alt+F1,Application Launcher"
    run /run/current-system/sw/bin/kwriteconfig6 --file kglobalshortcutsrc --group services --group wofi.desktop \
      --key _launch "Meta+R,none,Wofi"
  '';

  # Natural scrolling for the Dell touchpad (KWin reads kcminputrc on Wayland, not the libinput NixOS option)
  home.activation.touchpadNaturalScroll = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /run/current-system/sw/bin/kwriteconfig6 --file kcminputrc \
      --group Libinput --group 1160 --group 4639 --group "DELL08B8:00 0488:121F Touchpad" \
      --key NaturalScroll true
  '';

  xdg.enable = true;
  xdg.desktopEntries.wofi = {
    name = "Wofi";
    exec = "wofi --show drun";
    terminal = false;
    type = "Application";
  };

  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  home.file.".local/bin/dots".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/workspace/personal/dotfiles/dots";
}
