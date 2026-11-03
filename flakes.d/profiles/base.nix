{ ... }:
{
  imports = [
    ../modules/bootloader.nix
    ../modules/locale.nix
    ../modules/settings.nix
    ../modules/sshd.nix
  ];
}
