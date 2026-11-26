{
  flake.darwinModules.touchid = {
    security.pam.services.sudo_local.touchIdAuth = true;
  };
}
