{ ... }:
{
  imports = [ ./user-root.nix ];

  users.users.chuck.isNormalUser = true;
  users.users.chuck.extraGroups = [ "wheel" ];
  nix.settings.trusted-users = [ "chuck" ];

  users.users.chuck.hashedPasswordFile = "/persistent/secrets/chuck";
  users.users.chuck.initialPassword = "changeme";

  users.users.chuck.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
  ];

  preservation.preserveAt."/persistent".users.chuck.directories = [ "workspace" ];
  systemd.tmpfiles.settings.preservation."/home/chuck".d = {
    user = "chuck";
    group = "users";
    mode = "0700";
  };

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "chuck";
  services.displayManager.defaultSession = "labwc";
  services.displayManager.ly.x11Support = false;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.chuck =
    { pkgs, ... }:
    {
      home.stateVersion = "26.11";
      home.packages = [
        pkgs.alacritty
        pkgs.nerd-fonts.code-new-roman
      ];
      home.file.".bashrc".source = ./home/bashrc.sh;
      home.file.".bash_profile".source = ./home/bash_profile.sh;
      xdg.configFile."alacritty/alacritty.toml".source = ./home/alacritty.toml;
    };
}
