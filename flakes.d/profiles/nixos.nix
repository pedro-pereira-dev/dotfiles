{ ... }:
{
  imports = [
    ../modules/bootloader.nix
    ../modules/code.nix
    ../modules/display-manager-ly.nix
    ../modules/dots.nix
    ../modules/librewolf.nix
    ../modules/locale.nix
    ../modules/preservation.nix
    ../modules/sshd.nix
    ../modules/user-chuck.nix
    ../modules/window-manager-labwc.nix
  ];
}
