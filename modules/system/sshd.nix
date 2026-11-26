{
  flake.nixosModules.sshd =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.dots.sshd;
    in
    {
      options.dots.sshd = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        preservation_volume = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      };

      config = lib.mkIf cfg.enable {
        services.openssh.enable = true;
        services.openssh.settings.KbdInteractiveAuthentication = false;
        services.openssh.settings.PasswordAuthentication = false;
        services.openssh.settings.PermitRootLogin = "no";

        services.openssh.hostKeys =
          lib.mkIf ((config.preservation.enable or false) && cfg.preservation_volume != null)
            [
              {
                path = "/${cfg.preservation_volume}/etc/ssh/ssh_host_ed25519_key";
                type = "ed25519";
              }
            ];
      };
    };
}
