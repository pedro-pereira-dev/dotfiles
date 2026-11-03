{
  inputs,
  pkgs,
  volumes,
  ...
}:
{
  users.users.root.hashedPassword = "!";
  nix.settings.trusted-users = [ "chuck" ];

  users.users.chuck.isNormalUser = true;
  users.users.chuck.extraGroups = [ "wheel" ];

  users.users.chuck.initialPassword = "changeme";
  users.users.chuck.hashedPasswordFile = "/${volumes.persistent}/secrets/chuck";

  users.users.chuck.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
  ];

  preservation.preserveAt."/${volumes.persistent}".users.chuck.directories = [ "workspace" ];
}
