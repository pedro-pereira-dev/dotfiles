{ ... }: {
  flake.modules.home-manager.vim = {
    xdg.configFile."nvim/init.lua".text = builtins.readFile ../hosts/_bra-m0234.d/nvim-init.lua;
  };
}
