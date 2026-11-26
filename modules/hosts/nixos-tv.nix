{ inputs, ... }:
{
  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation.url = "github:nix-community/preservation";
  };

  flake.nixosConfigurations.nixos-tv = inputs.nixpkgs.lib.nixosSystem {
    modules = [ inputs.self.nixosModules.nixos-tv ];
  };

  flake.nixosModules.nixos-tv =
    {
      config,
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

        ./_nixos-tv.d/nixos-tv-hardware-configuration.nix
        ./_nixos-tv.d/nixos-tv-disko.nix

        inputs.self.nixosModules.system
        inputs.self.nixosModules.bootloader
        inputs.self.nixosModules.user
        inputs.self.nixosModules.sshd
        inputs.self.nixosModules.login
        inputs.self.nixosModules.deck
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
    };
}
