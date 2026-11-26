{
  flake.darwinModules.bash =
    { config, pkgs, ... }:
    {
      environment.shells = [ pkgs.bashInteractive ];
      launchd.user.envVariables.LC_COLLATE = "C";
      programs.bash = {
        completion.enable = true;
        enable = true;
      };
      users.users.${config.system.primaryUser}.shell = pkgs.bashInteractive;
    };
}
