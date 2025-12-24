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
	-- ansible
	"ansible-language-server",
	"ansible-lint",
	-- bash / shell
	"bash-language-server",
	"shellcheck",
	"shfmt",
	-- css / scss
	"prettier",
	"css-lsp",
	"stylelint",
	-- json
	"json-lsp",
	"jsonlint",
	-- lua
	"lua-language-server",
	"luacheck",
	"stylua",
	-- vue with typescript support
	"oxlint",
	"prettier",
	"vtsls",
	"vue-language-server",
	-- yaml
	"yaml-language-server",
	"yamllint",
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
	-- vue with typescript support
	javascript = { "prettier" },
	javascriptreact = { "prettier" },
	typescript = { "prettier" },
	typescriptreact = { "prettier" },
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
	-- vue with typescript support
	javascript = { "oxlint" },
	javascriptreact = { "oxlint" },
	typescript = { "oxlint" },
	typescriptreact = { "oxlint" },
	vue = { "oxlint" },
}

local setup_by_lsp = {
	-- vue with typescript support
	vtsls = {
		settings = {
			vtsls = {
				tsserver = {
					globalPlugins = {
						{
							name = "@vue/typescript-plugin",
							location = vim.fn.stdpath("data")
								.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
							languages = { "vue" },
							configNamespace = "typescript",
						},
					},
				},
			},
		},
		filetypes = {
			"javascript",
			"javascript.jsx",
			"javascriptreact",
			"typescript",
			"typescript.tsx",
			"typescriptreact",
			"vue",
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

-- -- adds custom color palette
-- local custom_black = "#2e3440"
-- local custom_red = "#ff3242"
-- local custom_green = "#44bc44"
-- local custom_yellow = "#ff9400"
-- local custom_blue = "#0883ff"
-- local custom_magenta = "#d930d9"
-- local custom_cyan = "#00d8eb"
-- local custom_white = "#d8dee9"
-- local custom_bright_black = "#4c566a"
-- local custom_bright_red = "#ff6e6e"
-- local custom_bright_green = "#9ec875"
-- local custom_bright_yellow = "#ffaf00"
-- local custom_bright_blue = "#47bfe6"
-- local custom_bright_magenta = "#d294ff"
-- local custom_bright_cyan = "#8ae2f0"
-- local custom_bright_white = "#eceff4"
-- local custom_background = "#000000"
-- local custom_foreground = "#d2d1e6"
-- -- configures colorscheme
-- vim.cmd.highlight("clear")
-- for hl_group, attrs in pairs(vim.api.nvim_get_hl(0, {})) do
-- 	if attrs.bg then attrs.bg = custom_background end
-- 	if attrs.fg then attrs.fg = custom_foreground end
-- 	vim.api.nvim_set_hl(0, hl_group, attrs)
-- end

-- vim.api.nvim_set_hl(0, "DiagnosticError", {guifg=#eb6f92})
-- vim.api.nvim_set_hl(0, "DiagnosticWarn", {guifg=#f6c177})
-- vim.api.nvim_set_hl(0, "DiagnosticInfo", {guifg=#66aeca})
-- vim.api.nvim_set_hl(0, "DiagnosticHint", {guifg=#31748f})
-- vim.api.nvim_set_hl(0, "DiagnosticOk", {ctermfg=10 guifg=NvimLightGreen})
-- vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", {guifg=#eb6f92 guibg=#2e202f})
-- vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", {guifg=#f6c177 guibg=#2f282c})
-- vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", {guifg=#66aeca guibg=#212635})
-- vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", {guifg=#31748f guibg=#1b202f})
-- vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", {guifg=#c4a7e7})
-- vim.api.nvim_set_hl(0, "DiagnosticDeprecated", {cterm=strikethrough gui=strikethrough guisp=NvimLightRed})
-- vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", {guifg=#eb6f92 guibg=#4e2d40})
-- vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", {guifg=#f6c177 guibg=#504239})
-- vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", {guifg=#66aeca guibg=#2c3d4e})
-- vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", {guifg=#31748f guibg=#1f2e3f})
-- vim.api.nvim_set_hl(0, "DiagnosticUnderlineOk", {cterm=underline gui=underline guisp=NvimLightGreen})

-- vim.api.nvim_set_hl(0, "SpecialKey", {guifg=#6e6a86})
-- vim.api.nvim_set_hl(0, "EndOfBuffer", {guifg=#191724})
-- vim.api.nvim_set_hl(0, "TermCursor", {cterm=reverse gui=reverse})
-- vim.api.nvim_set_hl(0, "NonText", {guifg=#26233a})
-- vim.api.nvim_set_hl(0, "Directory", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "ErrorMsg", {guifg=#eb6f92})
-- vim.api.nvim_set_hl(0, "IncSearch", {guifg=#16141f guibg=#ebbcba})
-- vim.api.nvim_set_hl(0, "Search", {guifg=#e0def4 guibg=#385366})
-- vim.api.nvim_set_hl(0, "MoreMsg", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "ModeMsg", {guifg=#908caa})
-- vim.api.nvim_set_hl(0, "LineNr", {guifg=#524f67})
-- vim.api.nvim_set_hl(0, "LineNrAbove", {guifg=#524f67})
-- vim.api.nvim_set_hl(0, "LineNrBelow", {guifg=#524f67})
-- vim.api.nvim_set_hl(0, "CursorLineNr", {cterm=bold gui=bold guifg=#9e6fd8})
-- vim.api.nvim_set_hl(0, "Question", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "StatusLine", {guifg=#a4a2b6})
-- vim.api.nvim_set_hl(0, "StatusLineNC", {guifg=#524f67})
-- vim.api.nvim_set_hl(0, "WinSeparator", {guifg=#16141f})
-- vim.api.nvim_set_hl(0, "VertSplit", {guifg=#16141f})
-- vim.api.nvim_set_hl(0, "Title", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "Visual", {guibg=#332d41})
-- vim.api.nvim_set_hl(0, "WarningMsg", {guifg=#f6c177})
-- vim.api.nvim_set_hl(0, "WildMenu", {guibg=#332d41})
-- vim.api.nvim_set_hl(0, "Folded", {guifg=#66aeca guibg=#21202e})
-- vim.api.nvim_set_hl(0, "FoldColumn", {guifg=#6e6a86})
-- vim.api.nvim_set_hl(0, "DiffAdd", {guibg=#2c2e38})
-- vim.api.nvim_set_hl(0, "DiffChange", {guibg=#252e3d})
-- vim.api.nvim_set_hl(0, "DiffDelete", {guibg=#392435})
-- vim.api.nvim_set_hl(0, "DiffText", {guibg=#304456})
-- vim.api.nvim_set_hl(0, "SignColumn", {guifg=#524f67})
-- vim.api.nvim_set_hl(0, "Conceal", {guifg=#6e6a86})
-- vim.api.nvim_set_hl(0, "SpellBad", {cterm=undercurl gui=undercurl guisp=#eb6f92})
-- vim.api.nvim_set_hl(0, "SpellCap", {cterm=undercurl gui=undercurl guisp=#f6c177})
-- vim.api.nvim_set_hl(0, "SpellRare", {cterm=undercurl gui=undercurl guisp=#31748f})
-- vim.api.nvim_set_hl(0, "SpellLocal", {cterm=undercurl gui=undercurl guisp=#66aeca})
-- vim.api.nvim_set_hl(0, "Pmenu", {guifg=#e0def4 guibg=#191724})
-- vim.api.nvim_set_hl(0, "PmenuSel", {guibg=#332d41})
-- vim.api.nvim_set_hl(0, "PmenuMatch", {guifg=#c4a7e7 guibg=#191724})
-- vim.api.nvim_set_hl(0, "PmenuMatchSel", {guifg=#c4a7e7 guibg=#332d41})
-- vim.api.nvim_set_hl(0, "PmenuSbar", {guibg=#23212e})
-- vim.api.nvim_set_hl(0, "PmenuThumb", {guibg=#524f67})
-- vim.api.nvim_set_hl(0, "TabLine", {guifg=#524f67 guibg=#26233a})
-- vim.api.nvim_set_hl(0, "TabLineSel", {cterm=bold gui=bold guifg=#e0def4 guibg=#21202e})
-- vim.api.nvim_set_hl(0, "CursorColumn", {guibg=#191724})
-- vim.api.nvim_set_hl(0, "CursorLine", {guibg=#403d52})
-- vim.api.nvim_set_hl(0, "ColorColumn", {guibg=#16141f})
-- vim.api.nvim_set_hl(0, "QuickFixLine", {cterm=bold gui=bold guibg=#332d41})
-- vim.api.nvim_set_hl(0, "Whitespace", {guifg=#524f67})
-- vim.api.nvim_set_hl(0, "NormalNC", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "NormalFloat", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "MsgArea", {guifg=#908caa})
-- vim.api.nvim_set_hl(0, "FloatBorder", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "Cursor", {guifg=#191724 guibg=#e0def4})
-- vim.api.nvim_set_hl(0, "FloatTitle", {guifg=#5790a9})
-- vim.api.nvim_set_hl(0, "RedrawDebugNormal", {cterm=reverse gui=reverse})
-- vim.api.nvim_set_hl(0, "Underlined", {cterm=underline gui=underline})
-- vim.api.nvim_set_hl(0, "lCursor", {guifg=#191724 guibg=#e0def4})
-- vim.api.nvim_set_hl(0, "CursorIM", {guifg=#191724 guibg=#e0def4})
-- vim.api.nvim_set_hl(0, "Substitute", {guifg=#16141f guibg=#eb6f92})
-- vim.api.nvim_set_hl(0, "VisualNOS", {guibg=#332d41})
-- vim.api.nvim_set_hl(0, "Normal", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "Character", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "Constant", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "Number", {guifg=#eb6f92})
-- vim.api.nvim_set_hl(0, "Float", {guifg=#eb6f92})
-- vim.api.nvim_set_hl(0, "Statement", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "Keyword", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "PreProc", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "Type", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "Special", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "Debug", {guifg=#ebbcba})
-- vim.api.nvim_set_hl(0, "LspCodeLens", {guifg=#6e6a86})
-- vim.api.nvim_set_hl(0, "LspInlayHint", {guifg=#67637d guibg=#23212e})
-- vim.api.nvim_set_hl(0, "LspReferenceRead", {guibg=#524f67})
-- vim.api.nvim_set_hl(0, "LspReferenceText", {guibg=#524f67})
-- vim.api.nvim_set_hl(0, "LspReferenceWrite", {guibg=#524f67})
-- vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", {cterm=bold gui=bold guibg=#232030})
-- vim.api.nvim_set_hl(0, "Comment", {cterm=italic gui=italic guifg=#6e6a86})
-- vim.api.nvim_set_hl(0, "@variable", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@variable.builtin", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@variable.parameter", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@variable.parameter.builtin", {guifg=#f2c790})
-- vim.api.nvim_set_hl(0, "@module.builtin", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@label", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "String", {guifg=#f6c177})
-- vim.api.nvim_set_hl(0, "@string.regexp", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@string.escape", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@type.builtin", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@property", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "Identifier", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "Function", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@constructor", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "Operator", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@keyword", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@punctuation.special", {guifg=#66aeca})
-- vim.api.nvim_set_hl(0, "@comment.error", {guifg=#eb6f92})
-- vim.api.nvim_set_hl(0, "@comment.warning", {guifg=#f6c177})
-- vim.api.nvim_set_hl(0, "@comment.note", {guifg=#31748f})
-- vim.api.nvim_set_hl(0, "@comment.todo", {guifg=#66aeca})
-- vim.api.nvim_set_hl(0, "Todo", {guifg=#191724 guibg=#f6c177})
-- vim.api.nvim_set_hl(0, "@markup.strong", {cterm=bold gui=bold})
-- vim.api.nvim_set_hl(0, "@markup.italic", {cterm=italic gui=italic})
-- vim.api.nvim_set_hl(0, "@markup.strikethrough", {cterm=strikethrough gui=strikethrough})
-- vim.api.nvim_set_hl(0, "@markup.underline", {cterm=underline gui=underline})
-- vim.api.nvim_set_hl(0, "@markup.link", {guifg=#31748f})
-- vim.api.nvim_set_hl(0, "Added", {ctermfg=10 guifg=NvimLightGreen})
-- vim.api.nvim_set_hl(0, "Removed", {ctermfg=9 guifg=NvimLightRed})
-- vim.api.nvim_set_hl(0, "Changed", {ctermfg=14 guifg=NvimLightCyan})
-- vim.api.nvim_set_hl(0, "@tag.builtin", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@markup.heading.1.delimiter.vimdoc", {cterm=underdouble,nocombine gui=underdouble,nocombine guifg=bg guibg=bg guisp=fg})
-- vim.api.nvim_set_hl(0, "@markup.heading.2.delimiter.vimdoc", {cterm=underline,nocombine gui=underline,nocombine guifg=bg guibg=bg guisp=fg})
-- vim.api.nvim_set_hl(0, "FloatShadow", {ctermbg=0 guibg=NvimDarkGrey4 blend=80})
-- vim.api.nvim_set_hl(0, "FloatShadowThrough", {ctermbg=0 guibg=NvimDarkGrey4 blend=100})
-- vim.api.nvim_set_hl(0, "MatchParen", {cterm=bold gui=bold guifg=#5790a9 guibg=#304456})
-- vim.api.nvim_set_hl(0, "RedrawDebugClear", {ctermfg=0 ctermbg=11 guibg=NvimDarkYellow})
-- vim.api.nvim_set_hl(0, "RedrawDebugComposed", {ctermfg=0 ctermbg=10 guibg=NvimDarkGreen})
-- vim.api.nvim_set_hl(0, "RedrawDebugRecompose", {ctermfg=0 ctermbg=9 guibg=NvimDarkRed})
-- vim.api.nvim_set_hl(0, "Error", {guifg=#eb6f92})
-- vim.api.nvim_set_hl(0, "NvimInternalError", {ctermfg=9 ctermbg=9 guifg=Red guibg=Red})
-- vim.api.nvim_set_hl(0, "@markup.raw.markdown_inline", {guifg=#66aeca guibg=#26233a})
-- vim.api.nvim_set_hl(0, "illuminatedWord", {guibg=#403d52})
-- vim.api.nvim_set_hl(0, "illuminatedCurWord", {guibg=#403d52})
-- vim.api.nvim_set_hl(0, "IlluminatedWordWrite", {guibg=#403d52})
-- vim.api.nvim_set_hl(0, "IlluminatedWordText", {guibg=#403d52})
-- vim.api.nvim_set_hl(0, "IlluminatedWordRead", {guibg=#403d52})
-- vim.api.nvim_set_hl(0, "NotifyINFOTitle", {guifg=#66aeca})
-- vim.api.nvim_set_hl(0, "NotifyINFOIcon", {guifg=#66aeca})
-- vim.api.nvim_set_hl(0, "NotifyBackground", {guifg=#e0def4 guibg=#191724})
-- vim.api.nvim_set_hl(0, "gitcommitFirstLine", {cterm=italic gui=italic guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "gitcommitSummary", {cterm=italic gui=italic guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "helpExample", {guifg=#6e6a86})
-- vim.api.nvim_set_hl(0, "diffIndexLine", {guifg=#c4a7e7})
-- vim.api.nvim_set_hl(0, "diffLine", {guifg=#6e6a86})
-- vim.api.nvim_set_hl(0, "diffFile", {guifg=#66aeca})
-- vim.api.nvim_set_hl(0, "diffNewFile", {guifg=#ebbcba})
-- vim.api.nvim_set_hl(0, "diffOldFile", {guifg=#f6c177})
-- vim.api.nvim_set_hl(0, "diffChanged", {guifg=#ebbcba})
-- vim.api.nvim_set_hl(0, "diffRemoved", {guifg=#eb6f92})
-- vim.api.nvim_set_hl(0, "diffAdded", {guifg=#31748f})
-- vim.api.nvim_set_hl(0, "healthWarning", {guifg=#f6c177})
-- vim.api.nvim_set_hl(0, "healthSuccess", {guifg=#95b1ac})
-- vim.api.nvim_set_hl(0, "healthError", {guifg=#eb6f92})
-- vim.api.nvim_set_hl(0, "LspInfoBorder", {guifg=#5790a9})
-- vim.api.nvim_set_hl(0, "qfLineNr", {guifg=#6e6a86})
-- vim.api.nvim_set_hl(0, "qfFileName", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "htmlH2", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "htmlH1", {cterm=bold gui=bold guifg=#c4a7e7})
-- vim.api.nvim_set_hl(0, "helpCommand", {guifg=#e0def4 guibg=#21202e})
-- vim.api.nvim_set_hl(0, "debugPC", {guibg=#191724})
-- vim.api.nvim_set_hl(0, "debugBreakpoint", {guifg=#66aeca guibg=#212635})
-- vim.api.nvim_set_hl(0, "Italic", {cterm=italic gui=italic guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "NormalSB", {guifg=#a4a2b6 guibg=#191724})
-- vim.api.nvim_set_hl(0, "SignColumnSB", {guifg=#524f67 guibg=#191724})
-- vim.api.nvim_set_hl(0, "Foo", {guifg=#e0def4 guibg=#9e6fd8})
-- vim.api.nvim_set_hl(0, "@punctuation.bracket", {guifg=#66aeca})
-- vim.api.nvim_set_hl(0, "@variable.member", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@lsp.type.unresolvedReference", {cterm=undercurl gui=undercurl guisp=#eb6f92})
-- vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", {guifg=#f6c177})
-- vim.api.nvim_set_hl(0, "@comment.hint", {guifg=#31748f})
-- vim.api.nvim_set_hl(0, "IblScope", {cterm=nocombine gui=nocombine guifg=#c4a7e7})
-- vim.api.nvim_set_hl(0, "IblIndent", {cterm=nocombine gui=nocombine guifg=#403d52})
-- vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", {cterm=nocombine gui=nocombine guifg=#c4a7e7})
-- vim.api.nvim_set_hl(0, "IndentBlanklineChar", {cterm=nocombine gui=nocombine guifg=#403d52})
-- vim.api.nvim_set_hl(0, "VisualNonText", {guifg=#6e6a86 guibg=#332d41})
-- vim.api.nvim_set_hl(0, "TreesitterContextBottom", {cterm=underline gui=underline guisp=#c4a7e7})
-- vim.api.nvim_set_hl(0, "Bold", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@markup.list", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@tag.javascript", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@tag.tsx", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@tag.delimiter", {guifg=#908caa})
-- vim.api.nvim_set_hl(0, "@punctuation.special.markdown", {guifg=#ebbcba})
-- vim.api.nvim_set_hl(0, "@punctuation.delimiter", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@markup.list.unchecked", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@markup.list.markdown", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@markup.list.checked", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@markup.emphasis", {cterm=italic gui=italic})
-- vim.api.nvim_set_hl(0, "@keyword.repeat", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@keyword.operator", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@keyword.function", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@keyword.conditional", {cterm=bold gui=bold guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@constructor.tsx", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "@comment.info", {guifg=#66aeca})
-- vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", {cterm=bold gui=bold guifg=#66aeca})
-- vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", {cterm=bold gui=bold guifg=#95b1ac})
-- vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", {cterm=bold gui=bold guifg=#9e6fd8})
-- vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", {cterm=bold gui=bold guifg=#f6c177})
-- vim.api.nvim_set_hl(0, "@markup.heading.5.markdown", {cterm=bold gui=bold guifg=#31748f})
-- vim.api.nvim_set_hl(0, "@markup.heading.6.markdown", {cterm=bold gui=bold guifg=#c4a7e7})
-- vim.api.nvim_set_hl(0, "@markup.heading.7.markdown", {cterm=bold gui=bold guifg=#ebbcba})
-- vim.api.nvim_set_hl(0, "@markup.heading.8.markdown", {cterm=bold gui=bold guifg=#eb6f92})
-- vim.api.nvim_set_hl(0, "netrwMarkFile", {cterm=bold gui=bold guifg=#9e6fd8 guibg=#342948})
-- vim.api.nvim_set_hl(0, "netrwSpecial", {guifg=#ebbcba})
-- vim.api.nvim_set_hl(0, "netrwBak", {guifg=#66aeca})
-- vim.api.nvim_set_hl(0, "netrwCompress", {guifg=#9ccfd8})
-- vim.api.nvim_set_hl(0, "netrwTreeBar", {guifg=#c4a7e7})
-- vim.api.nvim_set_hl(0, "netrwExe", {guifg=#eb6f92})
-- vim.api.nvim_set_hl(0, "netrwSymLink", {cterm=bold gui=bold guifg=#ebbcba})
-- vim.api.nvim_set_hl(0, "netrwClassify", {cterm=bold gui=bold guifg=#66aeca})
-- vim.api.nvim_set_hl(0, "netrwDir", {cterm=bold gui=bold guifg=#66aeca})
-- vim.api.nvim_set_hl(0, "CmpItemMenu", {guifg=#6e6a86})
-- vim.api.nvim_set_hl(0, "CmpItemKindTabNine", {guifg=#31748f})
-- vim.api.nvim_set_hl(0, "CmpItemKindDefault", {guifg=#908caa})
-- vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", {guifg=#31748f})
-- vim.api.nvim_set_hl(0, "CmpItemKindCopilot", {guifg=#31748f})
-- vim.api.nvim_set_hl(0, "CmpItemKindCodeium", {guifg=#31748f})
-- vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", {guifg=#c4a7e7})
-- vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", {guifg=#c4a7e7})
-- vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", {cterm=strikethrough gui=strikethrough guifg=#524f67})
-- vim.api.nvim_set_hl(0, "CmpItemAbbr", {guifg=#e0def4})
-- vim.api.nvim_set_hl(0, "CmpGhostText", {guifg=#21202e})
-- vim.api.nvim_set_hl(0, "CmpDocumentationBorder", {guifg=#5790a9})
-- vim.api.nvim_set_hl(0, "CmpDocumentation", {guifg=#e0def4})
