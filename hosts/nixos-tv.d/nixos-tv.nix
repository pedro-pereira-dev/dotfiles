{
  config,
  inputs,
  lib,
  pkgs,
  volumes,
  ...
}:
let
  superuser = "chuck";
  user = "tv";
in
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ./nixos-tv-hardware-configuration.nix
    ./nixos-tv-disko.nix

    ../../flakes.d/modules/system.nix
    ../../flakes.d/modules/bootloader.nix
    ../../flakes.d/modules/user.nix
    ../../flakes.d/modules/sshd.nix
    ../../flakes.d/modules/login.nix
    ../../flakes.d/modules/deck.nix
  ];

  dots.system.hostName = "nixos-tv";
  dots.system.platform = "x86_64-linux";

  dots.bootloader.modules = [ "amdgpu" ];
  dots.bootloader.timeout = 0;

  preservation.enable = true;

  dots.users.${superuser} = {
    authorized_keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
    ];
    password = "/${volumes.secrets}/${superuser}";
    root = true;
  };

  dots.users.${user} = {
    authorized_keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
    ];
    groups = [
      "audio"
      "input"
      "video"
    ];
    password = "/${volumes.secrets}/${user}";
  };

  dots.sshd.enable = true;
  dots.sshd.preservation_volume = volumes.data;

  dots.deck.user = user;

  dots.login.autologin.user = user;
  dots.login.autologin.session = config.dots.deck.session;
}
