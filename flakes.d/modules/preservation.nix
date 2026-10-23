{ ... }: {
  preservation.enable = true;
  preservation.preserveAt."/persistent" = {
    directories = [
      {
        directory = "/var/lib/nixos";
        inInitrd = true;
      }
      "/var/lib/systemd/timers"
      "/var/log"
    ];
    files = [
      {
        file = "/etc/machine-id";
        inInitrd = true;
      }
    ];
  };

  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
}
