---@diagnostic disable: undefined-global
-- vim globals and options
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- appearance
vim.opt.cursorline = true
vim.opt.ruler = false
vim.opt.scrolloff = 20
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
-- splits direction
vim.opt.splitbelow = true
vim.opt.splitright = true
-- line numbers
vim.opt.number = true
vim.opt.numberwidth = 4
vim.opt.relativenumber = true
-- smart search
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- smart wrap
vim.opt.linebreak = true
vim.opt.smartindent = true
-- tab as spaces
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
-- timings
vim.opt.timeoutlen = 5000
vim.opt.updatetime = 500

-- auto commands
local custom_group = vim.api.nvim_create_augroup("custom_group", { clear = true })
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  group = custom_group,
  callback = function() (vim.hl or vim.highlight).on_yank() end,
})
vim.api.nvim_create_autocmd({ "CmdlineLeave" }, {
  group = custom_group,
  callback = function()
    local cmd = vim.fn.getcmdline()
    local commands = { "cn", "cp", "cfirst", "clast" }
    if vim.tbl_contains(commands, cmd) then vim.fn.setcmdline(cmd .. " | norm zzzv") end
  end,
})

-- WIP
vim.diagnostic.config({ virtual_text = true })
-- WIP

-- custom commands
vim.keymap.set("n", "<leader>e", ":Oil --preview<cr>", { desc = "Open explorer", silent = true })
vim.keymap.set("n", "<leader><tab>", ":FzfLua buffers<cr>", { silent = true, desc = "List open buffers" })
vim.keymap.set("n", "<leader>cl", ":Lazy<cr>", { silent = true, desc = "Open Lazy" })
vim.keymap.set("n", "<leader>cm", ":Mason<cr>", { silent = true, desc = "Open Mason" })
vim.keymap.set("n", "<leader>f", ":FzfLua grep_project<cr>", { silent = true, desc = "Search word" })
vim.keymap.set("v", "<leader>f", ":FzfLua grep_cword<cr>", { silent = true, desc = "Search word" })
vim.keymap.set("n", "<leader>gc", ":GitConflicts<cr>", { silent = true, desc = "List git conflicts" })
vim.keymap.set("n", "<leader>o", ":FzfLua files<cr>", { silent = true, desc = "Search file" })
vim.keymap.set("t", "<m-esc>", "<c-\\><c-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<m-q>", ":bwipeout<cr>", { silent = true, desc = "Close buffer" })
vim.keymap.set("n", "<m-Q>", "<c-w>q", { silent = true, desc = "Quit buffer" })
-- overridden defaults
vim.keymap.set("n", "<esc>", ":nohlsearch<cr>", { silent = true, desc = "Clear search highlights" })
vim.keymap.set("n", "<tab>", ":b#<cr>zzzv", { silent = true, desc = "Go to previous buffer" })
-- text indentation
vim.keymap.set("v", "<", "<gv", { desc = "Add indentation" })
vim.keymap.set("v", ">", ">gv", { desc = "Remove indentation" })
-- centered navigation
vim.keymap.set("n", "<c-d>", "<c-d>zzzv", { desc = "Center half page down" })
vim.keymap.set("n", "<c-u>", "<c-u>zzzv", { desc = "Center half page up" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zzzv'", { expr = true, desc = "Center previous occurrence" })
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zzzv'", { expr = true, desc = "Center next occurrence" })
vim.keymap.set("n", "{", "{zzzv", { desc = "Center previous paragraph" })
vim.keymap.set("n", "}", "}zzzv", { desc = "Center next paragraph" })
-- windows navigation
vim.keymap.set("n", "<m-h>", ":TmuxNavigateLeft<cr>", { silent = true })
vim.keymap.set("n", "<m-j>", ":TmuxNavigateDown<cr>", { silent = true })
vim.keymap.set("n", "<m-k>", ":TmuxNavigateUp<cr>", { silent = true })
vim.keymap.set("n", "<m-l>", ":TmuxNavigateRight<cr>", { silent = true })
-- clipboard manipulation
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste from clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
-- selection movement
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { silent = true, desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { silent = true, desc = "Move selection up" })

vim.api.nvim_create_user_command("GitConflicts", function()
  local cmd = { "rg", "--vimgrep", "--hidden", "<<<<<<< " }
  local out = vim.system(cmd):wait()
  local quickfixlist = {}
  if out.code == 0 and out.stdout and #out.stdout > 0 then
    for _, match in ipairs(vim.split(out.stdout, "\n")) do
      local parse = vim.split(match, ":")
      if #parse >= 2 then
        local entry = { filename = parse[1], lnum = parse[2], col = 1, text = "Git Conflict", type = "E" }
        table.insert(quickfixlist, entry)
      end
    end
  end
  vim.fn.setqflist(quickfixlist)
  vim.cmd("cwindow")
end, { desc = "List all git conflicts" })

-- uses plugin manager
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--branch=stable", "--filter=blob:none", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  defaults = { lazy = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "editorconfig",
        "fzf",
        "gzip",
        "man",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "osc52",
        "rplugin",
        "shada",
        "spellfile",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  rocks = { enabled = false },
  ui = { border = "single", pills = false, size = { height = 0.9, width = 140 }, title = "Lazy" },
  spec = {

    {
      -- adds colorscheme
      -- https://github.com/idr4n/github-monochrome.nvim
      "idr4n/github-monochrome.nvim",
      priority = 1000,
      opts = {
        on_highlights = function(hl, c)
          local util = require("github-monochrome.util")
          hl.DiagnosticUnderlineError = { bg = util.blend(c.error, 0.25, util.bg), fg = c.error }
          hl.DiagnosticUnderlineHint = { bg = util.blend(c.hint, 0.25, util.bg), fg = c.hint }
          hl.DiagnosticUnderlineInfo = { bg = util.blend(c.info, 0.25, util.bg), fg = c.info }
          hl.DiagnosticUnderlineWarn = { bg = util.blend(c.warning, 0.25, util.bg), fg = c.warning }
          hl.FloatBorder = { fg = c.fg }
        end,
        styles = { floats = "transparent" },
        transparent = true,
      },
      init = function() vim.cmd.colorscheme("github-monochrome-rosepine") end,
    },

    {
      -- adds fancy dashboard
      -- https://github.com/nvimdev/dashboard-nvim
      "nvimdev/dashboard-nvim",
      event = { "VimEnter" },
      opts = {
        config = {
          disable_move = true,
          footer = {
            "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
            "",
            "pedro-pereira-dev | https://pedro-pereira-dev.github.io",
          },
          header = {
            " ██████╗ ███████╗███╗   ██╗████████╗ ██████╗  ██████╗ ██╗   ██╗██╗███╗   ███╗",
            "██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝██╔═══██╗██╔═══██╗██║   ██║██║████╗ ████║",
            "██║  ███╗█████╗  ██╔██╗ ██║   ██║   ██║   ██║██║   ██║██║   ██║██║██╔████╔██║",
            "██║   ██║██╔══╝  ██║╚██╗██║   ██║   ██║   ██║██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
            "╚██████╔╝███████╗██║ ╚████║   ██║   ╚██████╔╝╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
            " ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝  ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
            "",
            "" .. vim.fn.getcwd():gsub(vim.env.HOME, "~"),
            "",
          },
          mru = { enable = false },
          project = { enable = false },
          shortcut = {
            { key = "o", group = "fg", action = "FzfLua files cwd_prompt=false", desc = "󰍉 Open" },
            { key = "e", group = "fg", action = "Oil --preview", desc = " Explore" },
            { key = "s", group = "fg", action = "Lazy sync", desc = "󰒲 Sync" },
            { key = "m", group = "fg", action = "Mason", desc = " Mason" },
            { key = "q", group = "fg", action = "cq", desc = " Reload" },
          },
        },
      },
    },

    {
      -- adds customized status line
      -- https://github.com/nvim-lualine/lualine.nvim
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      event = { "BufNewFile", "BufReadPre" },
      opts = function()
        local theme = require("lualine.themes.auto")
        for _, mode in ipairs({ "command", "inactive", "insert", "normal", "replace", "visual" }) do
          for _, section in ipairs({ "a", "b", "c" }) do
            theme[mode][section].bg = "#000"
          end
        end
        return {
          inactive_sections = {
            lualine_a = { { "filename", color = "NonText", file_status = false, path = 1 } },
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = { { "location", color = "NonText" }, { "progress", color = "NonText" } },
          },
          options = { theme = theme, component_separators = {}, section_separators = {}, refresh = {} },
          sections = {
            lualine_a = { { "filename", color = "LineNr", file_status = false, path = 1 } },
            lualine_b = { { function() return vim.bo.modified and "changed" or "" end, color = "Bold" } },
            lualine_c = { { "diagnostics", color = { bg = "#000" } } },
            lualine_x = { { "lsp_status", color = "LineNr" }, { "filetype", color = "LineNr" } },
            lualine_y = { { "branch", color = "CursorLineNr" } },
            lualine_z = { { "location", color = "LineNr" }, { "progress", color = "LineNr" } },
          },
        }
      end,
    },

    {
      -- adds fuzzy finder
      -- https://github.com/ibhagwan/fzf-lua
      "ibhagwan/fzf-lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      cmd = { "FzfLua" },
      opts = {
        buffers = { actions = { ["ctrl-x"] = false }, prompt = "" },
        files = { cwd_prompt = false, formatter = "path.filename_first", prompt = false },
        fzf_colors = true,
        fzf_opts = { ["--cycle"] = true },
        grep = { actions = { ["ctrl-g"] = false }, hidden = true, prompt = "" },
        keymap = { fzf = { ["alt-space"] = "select-all+accept", ["shift-tab"] = "up", ["tab"] = "down" } },
        winopts = {
          border = "single",
          height = 0.9,
          preview = { border = "single", layout = "vertical", vertical = "down:75%" },
          width = 140,
        },
      },
    },

    {
      -- adds file explorer
      -- https://github.com/stevearc/oil.nvim
      "stevearc/oil.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      cmd = { "Oil" },
      opts = {
        confirmation = { width = 140, border = "single" },
        keymaps = {
          ["<cr>"] = "actions.select",
          ["<esc>"] = "actions.close",
          ["h"] = "actions.parent",
          ["l"] = "actions.select",
          ["q"] = "actions.close",
        },
        lsp_file_methods = { enabled = false },
        progress = { width = 140, border = "single" },
        skip_confirm_for_simple_edits = true,
        use_default_keymaps = false,
        view_options = { show_hidden = true, natural_order = false },
        win_options = { signcolumn = "yes" },
      },
    },

    {
      -- integrates tmux and neovim navigation
      -- https://github.com/christoomey/vim-tmux-navigator
      "christoomey/vim-tmux-navigator",
      cmd = { "TmuxNavigateDown", "TmuxNavigateLeft", "TmuxNavigateRight", "TmuxNavigateUp" },
    },

    {
      -- adds lsp servers package manager
      -- https://github.com/mason-org/mason.nvim
      "mason-org/mason.nvim",
      opts = { ui = { border = "single", width = 140 } },
    },

    {
      -- installs lsp servers via mason
      -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      opts = {
        auto_update = true,
        ensure_installed = {
          -- lua
          "lua-language-server",
          "luacheck",
          "stylua",
          -- shell / bash
          "bash-language-server",
          "shellcheck",
          "shfmt",
          -- typescript
          "eslint_d",
          "prettier",
          "typescript-language-server",
          -- vue
          "eslint-lsp",
          "prettier",
          "vue-language-server",
        },
      },
    },

    {
      -- implements abstraction between mason and lsp config
      -- https://github.com/mason-org/mason-lspconfig.nvim
      "mason-org/mason-lspconfig.nvim",
      opts = {},
    },

    {
      -- integrates auto completion tool
      -- https://github.com/saghen/blink.cmp
      "saghen/blink.cmp",
      version = "*",
      event = { "InsertEnter" },
      opts = {
        completion = {
          accept = {
            -- experimental auto-brackets support
            auto_brackets = {
              enabled = true,
            },
          },
          menu = {
            draw = {
              treesitter = { "lsp" },
            },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
          },
          ghost_text = {
            enabled = vim.g.ai_cmp,
          },
        },
        sources = {
          -- adding any nvim-cmp sources here will enable them
          -- with blink.compat
          compat = {},
          default = { "lsp", "path", "snippets", "buffer" },
        },
        cmdline = {
          enabled = false,
        },
        keymap = {
          preset = "enter",
          ["<tab>"] = { "select_and_accept" },
        },
      },
    },

    {
      -- lsp
      "neovim/nvim-lspconfig",
      cmd = { "Mason" },
      event = { "BufNewFile", "BufReadPre" },
      opts = {
        servers = {
          -- lua_ls = {},
          ts_ls = {
            filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
            init_options = {
              plugins = {
                {
                  languages = { "vue" },
                  location = vim.fn.stdpath("data")
                      .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
                  name = "@vue/typescript-plugin",
                },
              },
            },
          },
          -- vue_ls = {},
        },
      },

      config = function(_, opts)
        local borders = {}
        for i, v in ipairs({ "┌", "─", "┐", "│", "┘", "─", "└", "│" }) do
          borders[i] = { v, "FloatBorder" }
        end
        local _open_floating_preview = vim.lsp.util.open_floating_preview
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
          opts = opts or {}
          opts.border = opts.border or borders
          return _open_floating_preview(contents, syntax, opts, ...)
        end

        require("mason-tool-installer").run_on_start()

        local lspconfig = require("lspconfig")
        for server, config in pairs(opts.servers) do
          config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
          lspconfig[server].setup(config)
        end
      end,
    },

    {
      -- integrates auto formatters
      -- https://github.com/stevearc/conform.nvim
      "stevearc/conform.nvim",
      cmd = { "SaveWithoutFormatter" },
      event = { "BufWritePre" },
      opts = {
        formatters_by_ft = {
          -- lua = { "stylua" },
          -- Use the "*" filetype to run formatters on all filetypes.
          ["*"] = { "codespell" },
          -- Use the "_" filetype to run formatters on filetypes that don't
          -- have other formatters configured.
          ["_"] = { "trim_whitespace" },
        },
      },
      config = function()
        require("conform").setup({
          default_format_opts = { lsp_format = "fallback" },
          formatters_by_ft = language_formatters,
          format_on_save = function(bufnr)
            if vim.b[bufnr].disable_autoformat then return end
            return { lsp_format = "fallback", timeout_ms = 500 }
          end,
        })

        vim.api.nvim_create_user_command("SaveWithoutFormat", function()
          vim.b.disable_autoformat = true
          vim.cmd.write()
          vim.b.disable_autoformat = false
        end, { desc = "Save document without format" })
      end,
    },

    -- treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      event = { "BufReadPre", "BufNewFile" },
      main = "nvim-treesitter.configs",
      opts = {
        auto_install = true,
        highlight = {
          enable = true,
          disable = function(_, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then return true end
          end,
        },
        incremental_selection = { enable = true },
        indent = { enable = true },
      },
      init = function(plugin)
        require("lazy.core.loader").add_to_rtp(plugin)
        require("nvim-treesitter.query_predicates")
      end,
    },

    -- other plugins ...

    -- fewfwe --
  },
})
