---@diagnostic disable: undefined-global

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.cursorline = true
vim.opt.ruler = false
vim.opt.scrolloff = 15
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.winborder = "single"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.number = true
vim.opt.numberwidth = 4
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.linebreak = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.timeoutlen = 5000
vim.opt.updatetime = 50

vim.keymap.set("t", "<m-esc>", "<c-\\><c-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<m-q>", ":bwipeout<cr>", { silent = true, desc = "Close buffer" })
vim.keymap.set("n", "<m-Q>", "<c-w>q", { silent = true, desc = "Quit buffer" })
vim.keymap.set("n", "<esc>", ":nohlsearch<cr>", { silent = true, desc = "Clear search highlights" })
vim.keymap.set("n", "<tab>", ":b#<cr>zzzv", { silent = true, desc = "Go to previous buffer" })
vim.keymap.set("n", "<c-d>", "<c-d>zzzv", { desc = "Center half page down" })
vim.keymap.set("n", "<c-u>", "<c-u>zzzv", { desc = "Center half page up" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zzzv'", { expr = true, desc = "Center previous occurrence" })
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zzzv'", { expr = true, desc = "Center next occurrence" })
vim.keymap.set("n", "{", "{zzzv", { desc = "Center previous paragraph" })
vim.keymap.set("n", "}", "}zzzv", { desc = "Center next paragraph" })
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste from clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>f", ":FzfLua grep_project<cr>", { silent = true, desc = "Search word" })
vim.keymap.set("v", "<leader>f", ":FzfLua grep_cword<cr>", { silent = true, desc = "Search word" })
vim.keymap.set("n", "<leader>e", ":Oil --preview<cr>", { silent = true })
vim.keymap.set("n", "<leader><tab>", ":FzfLua buffers<cr>", { silent = true })
vim.keymap.set("n", "<leader>o", ":FzfLua files<cr>", { silent = true })
vim.keymap.set("n", "<leader>gs", ":FzfLua git_status<cr>", { silent = true })
vim.keymap.set("n", "<leader>gb", ":FzfLua git_branches<cr>", { silent = true })
vim.keymap.set("n", "<leader>h", ":FzfLua highlights<cr>", { silent = true })
vim.keymap.set("n", "<leader>r", ":source %<cr>", { silent = true })
vim.keymap.set("n", "<leader>i", ":Inspect<cr>", { silent = true })

vim.diagnostic.config({ virtual_text = true })
vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank() end })
vim.api.nvim_create_autocmd("CmdlineLeave", {
  callback = function()
    local cmd = vim.fn.getcmdline()
    if vim.tbl_contains({ "cn", "cp", "cfirst", "clast" }, cmd) then
      vim.fn.setcmdline(cmd .. " | norm zzzv")
    end
  end,
})

local formatters_by_ft = {
  bash = { "shfmt" }, sh = { "shfmt" }, css = { "prettier" }, less = { "prettier" },
  scss = { "prettier" }, lua = { "stylua" }, javascript = { "prettier" },
  javascriptreact = { "prettier" }, typescript = { "prettier" },
  typescriptreact = { "prettier" }, vue = { "prettier" },
}

local linters_by_ft = {
  bash = { "shellcheck" }, sh = { "shellcheck" }, css = { "stylelint" },
  less = { "stylelint" }, scss = { "stylelint" }, lua = { "luacheck" },
  javascript = { "oxlint" }, javascriptreact = { "oxlint" },
  typescript = { "oxlint" }, typescriptreact = { "oxlint" }, vue = { "oxlint" },
}

-- Plugins are provided by Nix (flakes.d/users/superuser-neovim.nix) under nix-plugins.
-- Lazy runs in dev mode for all of them: it loads from disk and never clones or updates.
local nix_plugins = vim.fn.expand("~/.local/share/nvim-nix")
vim.opt.rtp:prepend(nix_plugins .. "/lazy.nvim")

-- Language servers that mason-lspconfig used to enable automatically.
vim.lsp.enable({ "lua_ls", "bashls", "ansiblels", "cssls", "jsonls", "yamlls", "vtsls", "vue_ls" })

require("lazy").setup({
  dev = { path = nix_plugins, patterns = { "" }, fallback = false },
  install = { missing = false },
  checker = { enabled = false },
  change_detection = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "editorconfig", "fzf", "gzip", "man", "matchit", "matchparen", "netrwPlugin",
        "osc52", "rplugin", "shada", "spellfile", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
  ui = { border = "single", pills = false, size = { height = 0.9, width = 140 }, title = "Lazy" },
  spec = {
    {
      "saghen/blink.cmp", version = "*", event = { "UIEnter" },
      opts = {
        cmdline = { keymap = {
          ["<cr>"] = { "accept_and_enter", "fallback" },
          ["<space>"] = { function(cmp) cmp.hide() end, "fallback" },
          ["<tab>"] = { "show_and_insert", "select_next" },
        } },
        completion = { menu = { draw = { treesitter = { "lsp" } } } },
        fuzzy = { sorts = { "exact", "score", "sort_text" } },
        keymap = { preset = "enter", ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
          ["<Tab>"] = { "select_next", "snippet_forward", "fallback" } },
      },
    },
    {
      "stevearc/conform.nvim", cmd = { "SaveWithoutFormatting" }, event = { "BufWritePre" },
      config = function()
        vim.api.nvim_create_user_command("SaveWithoutFormatting", function()
          vim.b.disable_autoformat = true
          vim.cmd.write()
          vim.b.disable_autoformat = false
        end, {})
        require("conform").setup({
          format_on_save = function(bufnr)
            if vim.b[bufnr].disable_autoformat then return end
            return { lsp_format = "fallback", timeout_ms = 500 }
          end,
          formatters_by_ft = formatters_by_ft,
        })
      end,
    },
    {
      "mfussenegger/nvim-lint", event = { "BufReadPost", "BufWritePost", "InsertLeave" },
      config = function()
        require("lint").linters_by_ft = linters_by_ft
        vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
          callback = function() require("lint").try_lint() end,
        })
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      config = function()
        -- nixpkgs ships the `main` branch: highlighting is started per buffer, no configs module.
        vim.api.nvim_create_autocmd("FileType", {
          callback = function(args) pcall(vim.treesitter.start, args.buf) end,
        })
      end,
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = { "saghen/blink.cmp" },
      event = { "BufNewFile", "BufReadPre" },
      config = function()
        local config = {
          settings = { vtsls = { tsserver = { globalPlugins = { {
            name = "@vue/typescript-plugin",
            location = nix_plugins .. "/vue-ts-plugin",
            -- resolved in superuser-neovim.nix to the typescript-plugin package dir

            languages = { "vue" }, configNamespace = "typescript",
          } } } } },
          filetypes = { "javascript", "javascript.jsx", "javascriptreact", "typescript", "typescript.tsx", "typescriptreact", "vue" },
        }
        config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities or {})
        vim.lsp.config("vtsls", config)
      end,
    },
    {
      "idr4n/github-monochrome.nvim", priority = 1000,
      opts = {
        on_highlights = function(hl, c)
          local util = require("github-monochrome.util")
          hl.DiagnosticUnderlineError = { bg = util.blend(c.error, 0.25, util.bg), fg = c.error }
          hl.DiagnosticUnderlineHint = { bg = util.blend(c.hint, 0.25, util.bg), fg = c.hint }
          hl.DiagnosticUnderlineInfo = { bg = util.blend(c.info, 0.25, util.bg), fg = c.info }
          hl.DiagnosticUnderlineWarn = { bg = util.blend(c.warning, 0.25, util.bg), fg = c.warning }
          hl.FloatBorder = { fg = c.fg }
        end,
        styles = { floats = "transparent" }, transparent = true,
      },
      init = function() vim.cmd.colorscheme("github-monochrome-rosepine") end,
    },
    {
      "ibhagwan/fzf-lua", dependencies = { "nvim-tree/nvim-web-devicons" }, cmd = { "FzfLua" },
      opts = {
        buffers = { actions = { ["ctrl-x"] = false }, prompt = "" },
        files = { cwd_prompt = false, formatter = "path.filename_first", prompt = false },
        fzf_colors = true, fzf_opts = { ["--cycle"] = true },
        grep = { actions = { ["ctrl-g"] = false }, hidden = true, prompt = "",
          rg_opts = '--color=always --column --glob="!.git" --line-number --max-columns=4096 --no-heading --smart-case -e' },
        keymap = { fzf = { ["alt-enter"] = "select-all+accept", ["shift-tab"] = "up", ["tab"] = "down" } },
        winopts = { border = "single", height = 0.9,
          preview = { border = "single", layout = "vertical", vertical = "down:70%" }, width = 140 },
      },
    },
    {
      "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" },
      event = { "BufNewFile", "BufReadPre" },
      opts = function()
        local theme = require("lualine.themes.auto")
        for _, mode in ipairs({ "command", "inactive", "insert", "normal", "replace", "visual" }) do
          for _, section in ipairs({ "a", "b", "c" }) do theme[mode][section].bg = "#000" end
        end
        return { options = { theme = theme }, sections = {
          lualine_a = { { "filename", color = "LineNr", file_status = false, path = 1 } },
          lualine_b = { { function() return vim.bo.modified and "changed" or "" end, color = "Bold" } },
          lualine_c = { { "diagnostics", color = { bg = "#000" } } },
          lualine_x = { { "lsp_status", color = "LineNr" }, { "filetype", color = "LineNr" } },
          lualine_y = { { "branch", color = "CursorLineNr" } },
          lualine_z = { { "location", color = "LineNr" }, { "progress", color = "LineNr" } },
        } }
      end,
    },
    {
      "stevearc/oil.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, cmd = { "Oil" },
      opts = {
        confirmation = { width = 140, border = "single" },
        keymaps = { ["<cr>"] = "actions.select", ["<esc>"] = "actions.close",
          ["h"] = "actions.parent", ["l"] = "actions.select", ["q"] = "actions.close" },
        lsp_file_methods = { enabled = false }, progress = { width = 140, border = "single" },
        skip_confirm_for_simple_edits = true, use_default_keymaps = false,
        view_options = { show_hidden = true, natural_order = false }, win_options = { signcolumn = "yes" },
      },
    },
    {
      "christoomey/vim-tmux-navigator",
      cmd = { "TmuxNavigateDown", "TmuxNavigateLeft", "TmuxNavigateRight", "TmuxNavigateUp" },
      init = function()
        vim.keymap.set("n", "<m-h>", ":TmuxNavigateLeft<cr>", { silent = true })
        vim.keymap.set("n", "<m-j>", ":TmuxNavigateDown<cr>", { silent = true })
        vim.keymap.set("n", "<m-k>", ":TmuxNavigateUp<cr>", { silent = true })
        vim.keymap.set("n", "<m-l>", ":TmuxNavigateRight<cr>", { silent = true })
      end,
    },
    {
      "nvimdev/dashboard-nvim", lazy = false,
      opts = { config = {
        disable_move = true,
        footer = { "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", "", "pedro-pereira-dev | https://pedro-pereira-dev.github.io" },
        header = {
          " ██████╗ ███████╗███╗   ██╗████████╗ ██████╗  ██████╗ ██╗   ██╗██╗███╗   ███╗",
          "██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝██╔═══██╗██╔═══██╗██║   ██║██║████╗ ████║",
          "██║  ███╗█████╗  ██╔██╗ ██║   ██║   ██║   ██║██║   ██║██║   ██║██║██╔████╔██║",
          "██║   ██║██╔══╝  ██║╚██╗██║   ██║   ██║   ██║██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
          "╚██████╔╝███████╗██║ ╚████║   ██║   ╚██████╔╝╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
          " ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝  ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
          "", "" .. vim.fn.getcwd():gsub(vim.env.HOME, "~"), "",
        },
        mru = { enable = false }, project = { enable = false },
        shortcut = {
          { key = "o", group = "fg", action = "FzfLua files cwd_prompt=false", desc = "󰍉 Open" },
          { key = "e", group = "fg", action = "Oil --preview", desc = " Explore" },
          { key = "q", group = "fg", action = "cq", desc = " Reload" },
        },
      } },
    },
    { "stevearc/quicker.nvim", event = "FileType qf", opts = {} },
    {
      "echasnovski/mini.nvim", event = { "BufNewFile", "BufReadPre" },
      config = function()
        require("mini.pairs").setup()
        require("mini.ai").setup()
        require("mini.splitjoin").setup()
      end,
    },
  },
})
