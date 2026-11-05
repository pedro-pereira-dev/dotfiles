{ lib, pkgs, ... }:
let
  # Directory name is the lazy.nvim plugin name (repo basename) so lazy's dev mode can resolve it.
  plugins = {
    "lazy.nvim" = pkgs.vimPlugins.lazy-nvim;
    "blink.cmp" = pkgs.vimPlugins.blink-cmp;
    "conform.nvim" = pkgs.vimPlugins.conform-nvim;
    "nvim-lint" = pkgs.vimPlugins.nvim-lint;
    "nvim-treesitter" = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
    "nvim-treesitter-textobjects" = pkgs.vimPlugins.nvim-treesitter-textobjects;
    "nvim-lspconfig" = pkgs.vimPlugins.nvim-lspconfig;
    "github-monochrome.nvim" = pkgs.vimPlugins.github-monochrome-nvim or (pkgs.vimUtils.buildVimPlugin {
      pname = "github-monochrome.nvim";
      version = "unstable-2026-01-25";
      src = pkgs.fetchFromGitHub {
        owner = "idr4n";
        repo = "github-monochrome.nvim";
        rev = "e77321ecd5a68f020d9c543592e222d7786169bf";
        hash = "sha256-2+ie8X+ssWuDzkW4QztsROA5eDiCIkQIGvTxUsibEK4=";
      };
    });
    "fzf-lua" = pkgs.vimPlugins.fzf-lua;
    "lualine.nvim" = pkgs.vimPlugins.lualine-nvim;
    "oil.nvim" = pkgs.vimPlugins.oil-nvim;
    "vim-tmux-navigator" = pkgs.vimPlugins.vim-tmux-navigator;
    "dashboard-nvim" = pkgs.vimPlugins.dashboard-nvim;
    "quicker.nvim" = pkgs.vimPlugins.quicker-nvim;
    "nvim-web-devicons" = pkgs.vimPlugins.nvim-web-devicons;
    "mini.nvim" = pkgs.vimPlugins.mini-nvim;
  };
in
{
  programs.neovim = {
    enable = true;
    # init.lua is owned by programs.neovim so it doesn't collide with a separate home.file.
    initLua = builtins.readFile ../../hosts/nixos-dell.d/dotfiles/nvim/init.lua;
    # Tools are only on PATH inside nvim, for LSP, conform and nvim-lint.
    extraPackages = with pkgs; [
      ansible-language-server
      ansible-lint
      bash-language-server
      shellcheck
      shfmt
      prettier
      vscode-langservers-extracted # cssls + jsonls
      stylelint
      lua-language-server
      luaPackages.luacheck
      stylua
      oxlint
      vtsls
      vue-language-server
      yaml-language-server
      yamllint
    ];
  };

  home.file =
    lib.mapAttrs' (
      name: pkg: lib.nameValuePair ".local/share/nvim-nix/${name}" { source = pkg; }
    ) plugins
    // {
      # vtsls loads the Vue TypeScript plugin from here.
      ".local/share/nvim-nix/vue-ts-plugin".source =
        "${pkgs.vue-language-server}/lib/language-tools/packages/language-server";
    };
}
