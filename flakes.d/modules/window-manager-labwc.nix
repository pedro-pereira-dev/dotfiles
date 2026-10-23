{ pkgs, ... }:
{
  programs.labwc.enable = true;
  programs.xwayland.enable = false;
  environment.systemPackages = [ pkgs.fuzzel ];

  environment.etc."xdg/labwc/rc.xml".text = ''
    <?xml version="1.0"?>
    <labwc_config>
      <keyboard>
        <default />
        <keybind key="W-r">
          <action name="Execute" command="fuzzel" />
        </keybind>
      </keyboard>
    </labwc_config>
  '';
}
