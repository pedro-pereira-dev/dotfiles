{ lib, pkgs, ... }:
let
  autoProfile = pkgs.writeShellScript "power-profile-auto" ''
    set -eu
    online=$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo 1)
    if [ "$online" = 1 ]; then
      profile=balanced
    else
      profile=power-saver
    fi
    ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set "$profile"
  '';
in
{
  services.power-profiles-daemon.enable = true;

  systemd.services.power-profile-auto = {
    description = "Select power profile from AC state";
    after = [ "power-profiles-daemon.service" ];
    wants = [ "power-profiles-daemon.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = autoProfile;
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", TAG+="systemd", ENV{SYSTEMD_WANTS}+="power-profile-auto.service"
  '';
}
