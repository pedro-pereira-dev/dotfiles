{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "dots";
      runtimeInputs = [
        pkgs.curl
        pkgs.git
        pkgs.gnutar
        pkgs.gzip
      ];
      text = ''
        dots="$HOME/workspace/personal/dotfiles/dots"
        if [[ -x $dots ]]; then exec "$dots" "$@"; fi
        exec bash -c "$(curl -fsSL https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/main/bootstrap)" -- "$@"
      '';
    })
  ];
}
