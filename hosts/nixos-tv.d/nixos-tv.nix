{ inputs, pkgs, ... }:
let
  user = "tv";
in
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "nixos-tv";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";

  console.keyMap = "pt-latin9";
  time.timeZone = "Europe/Lisbon";

  environment.systemPackages = with pkgs; [
    fastfetch
    wtype
  ];

  users.users.${user} = {
    extraGroups = [ "wheel" ];
    initialPassword = "changeme";
    isNormalUser = true;
  };

  programs.labwc.enable = true;

  # Hide the pointer at session start; it reappears on the next mouse movement.
  # labwc's HideCursor action is bound to an otherwise unused key, and autostart
  # sends that key once the compositor is running.
  environment.etc."xdg/labwc/rc.xml".text = ''
    <?xml version="1.0"?>
    <labwc_config>
      <keyboard>
        <keybind key="XF86Launch9">
          <action name="HideCursor" />
        </keybind>
      </keyboard>
    </labwc_config>
  '';

  environment.etc."xdg/labwc/autostart" = {
    mode = "0755";
    text = ''
      sleep 1
      ${pkgs.wtype}/bin/wtype -k XF86Launch9
    '';
  };

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = user;
  services.displayManager.defaultSession = "labwc";
  services.displayManager.ly.enable = true;
}
