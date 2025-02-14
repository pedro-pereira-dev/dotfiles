---@diagnostic disable: undefined-global

-- vim globals and options
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- appearance
vim.opt.cursorline = true
vim.opt.ruler = false
vim.opt.scrolloff = 15
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.winborder = "single"
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
-- line wrap and smart indentation
vim.opt.linebreak = true
vim.opt.smartindent = true
-- tab as spaces
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
-- timings
vim.opt.timeoutlen = 5000
vim.opt.updatetime = 50

-- custom commands
vim.keymap.set("t", "<m-esc>", "<c-\\><c-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<m-q>", ":bwipeout<cr>", { silent = true, desc = "Close buffer" })
vim.keymap.set("n", "<m-Q>", "<c-w>q", { silent = true, desc = "Quit buffer" })
-- overridden defaults
vim.keymap.set("n", "<esc>", ":nohlsearch<cr>", { silent = true, desc = "Clear search highlights" })
vim.keymap.set("n", "<tab>", ":b#<cr>zzzv", { silent = true, desc = "Go to previous buffer" })
-- centered navigation
vim.keymap.set("n", "<c-d>", "<c-d>zzzv", { desc = "Center half page down" })
vim.keymap.set("n", "<c-u>", "<c-u>zzzv", { desc = "Center half page up" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zzzv'", { expr = true, desc = "Center previous occurrence" })
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zzzv'", { expr = true, desc = "Center next occurrence" })
vim.keymap.set("n", "{", "{zzzv", { desc = "Center previous paragraph" })
vim.keymap.set("n", "}", "}zzzv", { desc = "Center next paragraph" })
-- clipboard manipulation
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

-- auto commands
vim.api.nvim_create_autocmd({ "TextYankPost" }, { callback = function() vim.highlight.on_yank() end })
vim.api.nvim_create_autocmd({ "CmdlineLeave" }, {
	callback = function()
		local cmd = vim.fn.getcmdline()
		local commands = { "cn", "cp", "cfirst", "clast" }
		if vim.tbl_contains(commands, cmd) then vim.fn.setcmdline(cmd .. " | norm zzzv") end
	end,
})

local ensure_installed = {
	-- bash / shell
	"bash-language-server",
	"shellcheck",
	"shfmt",
	-- css / scss
	"prettier",
	"css-lsp",
	"stylelint",
	-- lua
	"lua-language-server",
	"luacheck",
	"stylua",
	-- typescript
	"oxlint",
	"prettier",
	"typescript-language-server",
	-- vue
	"oxlint",
	"prettier",
	"vue-language-server",
}

local formatters_by_ft = {
	-- bash / shell
	bash = { "shfmt" },
	sh = { "shfmt" },
	-- css / scss
	css = { "prettier" },
	less = { "prettier" },
	scss = { "prettier" },
	-- lua
	lua = { "stylua" },
	-- typescript
	javascript = { "prettier" },
	javascriptreact = { "prettier" },
	typescript = { "prettier" },
	typescriptreact = { "prettier" },
	-- vue
	vue = { "prettier" },
}

local linters_by_ft = {
	-- bash / shell
	bash = { "shellcheck" },
	sh = { "shellcheck" },
	-- css / scss
	css = { "stylelint" },
	less = { "stylelint" },
	scss = { "stylelint" },
	-- lua
	lua = { "luacheck" },
	-- typescript
	javascript = { "oxlint" },
	javascriptreact = { "oxlint" },
	typescript = { "oxlint" },
	typescriptreact = { "oxlint" },
	-- vue
	vue = { "oxlint" },
}

local setup_by_lsp = {
	-- typescript and vue
	ts_ls = {
		filetypes = {
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
		},
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
}

-- bootstraps plugin manager
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--branch=stable", "--filter=blob:none", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
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
	ui = { border = "single", pills = false, size = { height = 0.9, width = 140 }, title = "Lazy" },
	spec = {

		-- installs auto completion tool
		-- https://github.com/saghen/blink.cmp
		{
			"saghen/blink.cmp",
			version = "*",
			-- event = { "InsertEnter" },
			event = { "UIEnter" },
			opts = {
				cmdline = {
					keymap = {
						["<cr>"] = { "accept_and_enter", "fallback" },
						["<space>"] = { function(cmp) cmp.hide() end, "fallback" },
						["<tab>"] = { "show_and_insert", "select_next" },
					},
				},
				completion = { menu = { draw = { treesitter = { "lsp" } } } },
				fuzzy = { sorts = { "exact", "score", "sort_text" } },
				keymap = {
					preset = "enter",
					["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
					["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
				},
			},
		},

		-- install code formatter
		-- https://github.com/stevearc/conform.nvim
		{
			"stevearc/conform.nvim",
			cmd = { "SaveWithoutFormatting" },
			event = { "BufWritePre" },
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

		-- installs linter
		-- https://github.com/mfussenegger/nvim-lint
		{
			"mfussenegger/nvim-lint",
			event = { "BufReadPost", "BufWritePost", "InsertLeave" },
			config = function()
				require("lint").linters_by_ft = linters_by_ft
				vim.api.nvim_create_autocmd(
					{ "BufReadPost", "BufWritePost", "InsertLeave" },
					{ callback = function() require("lint").try_lint() end }
				)
			end,
		},

		-- installs enhanced syntax highlighting based on treesitter
		-- https://github.com/nvim-treesitter/nvim-treesitter
		{
			"nvim-treesitter/nvim-treesitter",
			dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
			build = ":TSUpdate",
			event = { "BufReadPost", "BufWritePost", "InsertLeave" },
			main = "nvim-treesitter.configs",
			opts = {
				highlight = { enable = true },
				incremental_selection = { enable = true },
				indent = { enable = true },
				textobjects = { enable = true },
			},
		},

		-- installs lsp tooling package manager
		-- https://github.com/mason-org/mason.nvim
		{ "mason-org/mason.nvim", lazy = true, opts = { ui = { width = 140 } } },

		-- installs compatibility between mason and lspconfig
		-- https://github.com/mason-org/mason-lspconfig.nvim
		{ "mason-org/mason-lspconfig.nvim", lazy = true, opts = {} },

		-- installs lsp tooling via mason
		-- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
		{ "WhoIsSethDaniel/mason-tool-installer.nvim", lazy = true, opts = { ensure_installed = ensure_installed } },

		-- installs community lsp configurations
		-- https://github.com/neovim/nvim-lspconfig
		{
			"neovim/nvim-lspconfig",
			dependencies = {
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				"mason-org/mason-lspconfig.nvim",
				"mason-org/mason.nvim",
				"saghen/blink.cmp",
			},
			cmd = { "Mason" },
			event = { "BufNewFile", "BufReadPre" },
			config = function()
				require("mason-tool-installer").run_on_start()
				for server, config in pairs(setup_by_lsp) do
					local capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities or {})
					local new_config = vim.tbl_deep_extend("force", config, { capabilities })
					vim.lsp.config(server, new_config)
				end
			end,
		},

		-- adds colorscheme
		-- https://github.com/idr4n/github-monochrome.nvim
		{
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

		-- installs fuzzy finder
		-- https://github.com/ibhagwan/fzf-lua
		{
			"ibhagwan/fzf-lua",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			cmd = { "FzfLua" },
			opts = {
				buffers = { actions = { ["ctrl-x"] = false }, prompt = "" },
				files = { cwd_prompt = false, formatter = "path.filename_first", prompt = false },
				fzf_colors = true,
				fzf_opts = { ["--cycle"] = true },
				grep = {
					actions = { ["ctrl-g"] = false },
					hidden = true,
					prompt = "",
					rg_opts = '--color=always --column --glob="!.git" --line-number --max-columns=4096 --no-heading --smart-case -e',
				},
				keymap = { fzf = { ["alt-enter"] = "select-all+accept", ["shift-tab"] = "up", ["tab"] = "down" } },
				winopts = {
					border = "single",
					height = 0.9,
					preview = { border = "single", layout = "vertical", vertical = "down:70%" },
					width = 140,
				},
			},
		},

		-- adds customized status line
		-- https://github.com/nvim-lualine/lualine.nvim
		{
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
					options = { theme = theme },
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

		-- adds file explorer
		-- https://github.com/stevearc/oil.nvim
		{
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

		-- integrates tmux and neovim navigation
		-- https://github.com/christoomey/vim-tmux-navigator
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

		-- adds fancy dashboard
		-- https://github.com/nvimdev/dashboard-nvim
		{
			"nvimdev/dashboard-nvim",
			lazy = false,
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

		-- expands quickfix list functionality
		-- https://github.com/stevearc/quicker.nvim
		{ "stevearc/quicker.nvim", event = "FileType qf", opts = {} },

		-- treesitter stuff
		-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
		{ "nvim-treesitter/nvim-treesitter-textobjects", lazy = true },

		-- installs brackets pair automatic closing
		-- https://github.com/echasnovski/mini.pairs
		{ "echasnovski/mini.pairs", opts = {}, event = { "BufNewFile", "BufReadPre" } },

		-- installs extended text objects support
		-- https://github.com/echasnovski/mini.ai
		{ "echasnovski/mini.ai", opts = {}, event = { "BufNewFile", "BufReadPre" } },

		-- expands argument splitting
		-- https://github.com/echasnovski/mini.splitjoin
		{ "echasnovski/mini.splitjoin", opts = {}, event = { "BufNewFile", "BufReadPre" } },
	},
})
