{
  flake.darwinModules.darwin-karabiner =
    { config, ... }:
    let
      user = config.system.primaryUser;
      home = config.users.users.${user}.home;
      source = "${home}/workspace/personal/dotfiles/dotfiles/karabiner/karabiner.json";
    in
    {
      homebrew.casks = [ "karabiner-elements" ];
      home-manager.users.${user} =
        { config, ... }:
        {
          xdg.configFile."karabiner/karabiner.json" = {
            force = true;
            source = config.lib.file.mkOutOfStoreSymlink source;
          };
        };
    };
}
