{ inputs, pkgs, ... }:
{
  imports = [ ../modules/user-root.nix ];

  users.users.chuck.isNormalUser = true;
  users.users.chuck.extraGroups = [ "wheel" ];
  users.users.chuck.hashedPasswordFile = "/persistent/secrets/chuck";
  users.users.chuck.initialPassword = "changeme";
  users.users.chuck.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd"
  ];
  nix.settings.trusted-users = [ "chuck" ];

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
    { config, ... }:
    {
      imports = [
        inputs.ags.homeManagerModules.default
        ../modules/home/ags-deck-ui.nix
        ../modules/home-clone-dotfiles.nix
      ];
      home.stateVersion = "26.11";
      home.packages = [
        pkgs.alacritty
        pkgs.nerd-fonts.code-new-roman
        pkgs.delfin
        pkgs.fladder
        pkgs.jellyfin-desktop
        pkgs.jellyfin-mpv-shim
        pkgs.tsukimi
      ];
      home.file.".local/bin/dots".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/workspace/personal/dotfiles/dots";
      programs.bash.enable = true;
      programs.bash.bashrcExtra = builtins.readFile ../modules/home/bashrc.sh;
      programs.bash.profileExtra = builtins.readFile ../modules/home/bash_profile.sh;
      programs.ags-deck-ui.enable = true;
      xdg.configFile."alacritty/alacritty.toml".source = ../modules/home/alacritty.toml;
      xdg.configFile."labwc/autostart".text = "ags run &\n";
    };
}
