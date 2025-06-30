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

vim.keymap.set("n", "<leader><tab>", function()
	local keys = vim.api.nvim_replace_termcodes(":b<tab> ", true, false, true)
	vim.api.nvim_input(keys)
end)

vim.api.nvim_create_user_command("FilePick", function(opts)
	if vim.tbl_count(opts.fargs) == 0 then return end
	vim.cmd.edit({ args = opts.fargs })
end, {
	complete = function()
		local cmd = "git ls-files -c -o --exclude-standard"
		return vim.split(vim.trim(io.popen(cmd):read("*a")), "\n")
	end,
	force = true,
	nargs = "*",
})
vim.keymap.set("n", "<leader>o", function()
	local keys = vim.api.nvim_replace_termcodes(":FilePick <tab>", true, false, true)
	vim.api.nvim_input(keys)
end)
vim.keymap.set("n", "<leader>O", ":FzfLua files<cr>", { silent = true })

-- auto commands
vim.api.nvim_create_autocmd({ "TextYankPost" }, { callback = function() vim.highlight.on_yank() end })
vim.api.nvim_create_autocmd({ "CmdlineLeave" }, {
	callback = function()
		local cmd = vim.fn.getcmdline()
		local commands = { "cn", "cp", "cfirst", "clast" }
		if vim.tbl_contains(commands, cmd) then vim.fn.setcmdline(cmd .. " | norm zzzv") end
	end,
})

-- https://github.com/christoomey/vim-tmux-navigator
vim.api.nvim_create_user_command("Navigate", function(opts)
	local mappings = { h = "L", j = "D", k = "U", l = "R" }
	local wnr = vim.fn.winnr()
	vim.cmd("wincmd " .. opts.fargs[1])
	if wnr == vim.fn.winnr() then vim.fn.system("tmux select-pane -" .. mappings[opts.fargs[1]]) end
end, { nargs = 1 })
for _, d in ipairs({ "h", "j", "k", "l" }) do
	vim.keymap.set("n", "<m-" .. d .. ">", ":Navigate " .. d .. "<cr>", { silent = true })
end

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

		-- -- adds colorscheme
		-- -- https://github.com/idr4n/github-monochrome.nvim
		-- {
		-- 	"idr4n/github-monochrome.nvim",
		-- 	priority = 1000,
		-- 	opts = {
		-- 		on_highlights = function(hl, c)
		-- 			local util = require("github-monochrome.util")
		-- 			hl.DiagnosticUnderlineError = { bg = util.blend(c.error, 0.25, util.bg), fg = c.error }
		-- 			hl.DiagnosticUnderlineHint = { bg = util.blend(c.hint, 0.25, util.bg), fg = c.hint }
		-- 			hl.DiagnosticUnderlineInfo = { bg = util.blend(c.info, 0.25, util.bg), fg = c.info }
		-- 			hl.DiagnosticUnderlineWarn = { bg = util.blend(c.warning, 0.25, util.bg), fg = c.warning }
		-- 			hl.FloatBorder = { fg = c.fg }
		-- 		end,
		-- 		styles = { floats = "transparent" },
		-- 		transparent = true,
		-- 	},
		-- 	init = function() vim.cmd.colorscheme("github-monochrome-rosepine") end,
		-- },

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

		-- -- integrates tmux and neovim navigation
		-- -- https://github.com/christoomey/vim-tmux-navigator
		-- {
		-- 	"christoomey/vim-tmux-navigator",
		-- 	cmd = { "TmuxNavigateDown", "TmuxNavigateLeft", "TmuxNavigateRight", "TmuxNavigateUp" },
		-- 	init = function()
		-- 		vim.keymap.set("n", "<m-h>", ":TmuxNavigateLeft<cr>", { silent = true })
		-- 		vim.keymap.set("n", "<m-j>", ":TmuxNavigateDown<cr>", { silent = true })
		-- 		vim.keymap.set("n", "<m-k>", ":TmuxNavigateUp<cr>", { silent = true })
		-- 		vim.keymap.set("n", "<m-l>", ":TmuxNavigateRight<cr>", { silent = true })
		-- 	end,
		-- },

		-- -- adds fancy dashboard
		-- -- https://github.com/nvimdev/dashboard-nvim
		-- {
		-- 	"nvimdev/dashboard-nvim",
		-- 	lazy = false,
		-- 	opts = {
		-- 		config = {
		-- 			disable_move = true,
		-- 			footer = {
		-- 				"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
		-- 				"",
		-- 				"pedro-pereira-dev | https://pedro-pereira-dev.github.io",
		-- 			},
		-- 			header = {
		-- 				" ██████╗ ███████╗███╗   ██╗████████╗ ██████╗  ██████╗ ██╗   ██╗██╗███╗   ███╗",
		-- 				"██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝██╔═══██╗██╔═══██╗██║   ██║██║████╗ ████║",
		-- 				"██║  ███╗█████╗  ██╔██╗ ██║   ██║   ██║   ██║██║   ██║██║   ██║██║██╔████╔██║",
		-- 				"██║   ██║██╔══╝  ██║╚██╗██║   ██║   ██║   ██║██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
		-- 				"╚██████╔╝███████╗██║ ╚████║   ██║   ╚██████╔╝╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
		-- 				" ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝  ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
		-- 				"",
		-- 				"" .. vim.fn.getcwd():gsub(vim.env.HOME, "~"),
		-- 				"",
		-- 			},
		-- 			mru = { enable = false },
		-- 			project = { enable = false },
		-- 			shortcut = {
		-- 				{ key = "o", group = "fg", action = "FzfLua files cwd_prompt=false", desc = "󰍉 Open" },
		-- 				{ key = "e", group = "fg", action = "Oil --preview", desc = " Explore" },
		-- 				{ key = "s", group = "fg", action = "Lazy sync", desc = "󰒲 Sync" },
		-- 				{ key = "m", group = "fg", action = "Mason", desc = " Mason" },
		-- 				{ key = "q", group = "fg", action = "cq", desc = " Reload" },
		-- 			},
		-- 		},
		-- 	},
		-- },

		-- expands quickfix list functionality
		-- https://github.com/stevearc/quicker.nvim
		{ "stevearc/quicker.nvim", event = "FileType qf", opts = {} },

		-- -- treesitter stuff
		-- -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
		-- { "nvim-treesitter/nvim-treesitter-textobjects", lazy = true },

		-- -- installs brackets pair automatic closing
		-- -- https://github.com/echasnovski/mini.pairs
		-- { "echasnovski/mini.pairs", opts = {}, event = { "BufNewFile", "BufReadPre" } },

		-- -- installs extended text objects support
		-- -- https://github.com/echasnovski/mini.ai
		-- { "echasnovski/mini.ai", opts = {}, event = { "BufNewFile", "BufReadPre" } },

		-- -- expands code movement
		-- -- https://github.com/echasnovski/mini.move
		-- {
		-- 	"echasnovski/mini.move",
		-- 	opts = {
		-- 		mappings = {
		-- 			down = "J",
		-- 			left = "H",
		-- 			line_down = "",
		-- 			line_left = "",
		-- 			line_right = "",
		-- 			line_up = "",
		-- 			right = "L",
		-- 			up = "K",
		-- 		},
		-- 	},
		-- 	event = { "BufNewFile", "BufReadPre" },
		-- },

		-- expands argument splitting
		-- https://github.com/echasnovski/mini.splitjoin
		{ "echasnovski/mini.splitjoin", opts = {}, event = { "BufNewFile", "BufReadPre" } },

		-- -- expands surrounding actions
		-- -- https://github.com/echasnovski/mini.surround
		-- { "echasnovski/mini.surround", opts = {}, event = { "BufNewFile", "BufReadPre" } },

		--
	},
})

-- _G.basic_excludes = { ".git", "*.egg-info", "__pycache__", "wandb", "target" }
-- _G.ext_excludes = vim.list_extend(vim.deepcopy(_G.basic_excludes), { ".venv" })
--
-- local function scratch()
-- 	vim.bo.buftype = "nofile"
-- 	vim.bo.bufhidden = "wipe"
-- 	vim.bo.swapfile = false
-- end
--
-- local function pre_search()
-- 	if vim.bo.filetype == "netrw" then return vim.b.netrw_curdir, _G.basic_excludes, {} end
-- 	return vim.fn.getcwd(), _G.ext_excludes, {}
-- end
--
-- local function scratch_to_quickfix(close_qf)
-- 	local items, bufnr = {}, vim.api.nvim_get_current_buf()
-- 	for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
-- 		if line ~= "" then
-- 			local f, lnum, text = line:match("^([^:]+):(%d+):(.*)$")
-- 			if f and lnum then
-- 				-- for grep filename:line:text
-- 				table.insert(items, { filename = vim.fn.fnamemodify(f, ":p"), lnum = tonumber(lnum), text = text })
-- 			else
-- 				local lnum, text = line:match("^(%d+):(.*)$")
-- 				if lnum and text then
-- 					table.insert(
-- 						items,
-- 						{ filename = vim.fn.bufname(vim.fn.bufnr("#")), lnum = tonumber(lnum), text = text }
-- 					) -- for current buffer grep
-- 				else
-- 					table.insert(items, { filename = vim.fn.fnamemodify(line, ":p") }) -- for find results, only fnames
-- 				end
-- 			end
-- 		end
-- 	end
-- 	vim.api.nvim_buf_delete(bufnr, { force = true })
-- 	vim.fn.setqflist(items, "r")
-- 	vim.cmd("copen | cc")
-- 	if close_qf then vim.cmd("cclose") end
-- end
--
-- local function extcmd(cmd, qf, close_qf, novsplit)
-- 	output = vim.fn.systemlist(cmd)
-- 	if not output or #output == 0 then return end
-- 	vim.cmd(novsplit and "enew" or "vnew")
-- 	vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
-- 	scratch()
-- 	if qf then scratch_to_quickfix(close_qf) end
-- end
--
-- vim.keymap.set("x", "<leader>p", '"_dP')
--
-- vim.keymap.set("n", "<leader>x", scratch_to_quickfix)
-- vim.keymap.set("n", "<leader>gl", function() extcmd("git log --oneline") end)
-- vim.keymap.set("n", "<leader>gd", function() extcmd("git diff") end)
-- vim.keymap.set("n", "<leader>gb", function() extcmd("git blame " .. vim.fn.expand("%"), false, false, true) end)
-- -- vim.keymap.set("n", "<leader>gs", function() extcmd("git show " .. vim.fn.expand("<cword>")) end)
-- vim.keymap.set("n", "<leader>gc", function() extcmd("git diff --name-only --diff-filter=U", true) end)
-- vim.keymap.set("n", "<leader>ss", function()
-- 	vim.ui.input({ prompt = "> " }, function(p)
-- 		if p then extcmd("grep -in '" .. p .. "' " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)), false) end
-- 	end)
-- end)
-- vim.keymap.set("n", "<leader>sg", function()
-- 	vim.ui.input({ prompt = "> " }, function(p)
-- 		if p then
-- 			local path, excludes, ex = pre_search()
-- 			for _, pat in ipairs(excludes) do
-- 				table.insert(ex, string.format("--exclude-dir='%s'", pat))
-- 			end
-- 			extcmd(string.format("grep -IEnr %s '%s' %s", table.concat(ex, " "), p, path), true)
-- 		end
-- 	end)
-- end)
--
-- vim.keymap.set("n", "<leader>sf", function()
-- 	vim.ui.input({ prompt = "> " }, function(p)
-- 		if p then
-- 			local path, excludes, ex = pre_search()
-- 			for _, pat in ipairs(excludes) do
-- 				table.insert(ex, string.format("-path '*%s*' -prune -o", pat))
-- 			end
-- 			extcmd(
-- 				string.format("find %s %s -path '*%s*' -print", vim.fn.shellescape(path), table.concat(ex, " "), p),
-- 				true,
-- 				true
-- 			)
-- 		end
-- 	end)
-- end)
--
-- vim.keymap.set("n", "<leader>c", function()
-- 	vim.ui.input({ prompt = "> " }, function(c)
-- 		if c then extcmd(c) end
-- 	end)
-- end)
--

-- -- https://www.chrisdeluca.me/2022/01/12/diy-neovim-fzy.html
-- vim.api.nvim_create_user_command("TestePick", function()
-- 	local width = vim.o.columns - 4
-- 	local height = 11
-- 	if vim.o.columns >= 85 then width = 80 end
-- 	vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
-- 		relative = "editor",
-- 		-- style = "minimal",
-- 		-- border = "shadow",
-- 		noautocmd = true,
-- 		width = width,
-- 		height = height,
-- 		col = math.min((vim.o.columns - width) / 2),
-- 		row = math.min((vim.o.lines - height) / 2 - 1),
-- 	})
-- 	local file = vim.fn.tempname()
-- 	vim.fn.termopen("rg --glob '!**/.git/*' --hidden --files | fzf > " .. file, {
-- 		on_exit = function()
-- 			vim.api.nvim_command("bdelete!")
-- 			local f = io.open(file, "r")
-- 			local stdout = f:read("*all")
-- 			f:close()
-- 			os.remove(file)
-- 			if #stdout > 0 then vim.api.nvim_command("edit " .. stdout) end
-- 		end,
-- 	})
-- end, {})
-- vim.keymap.set("n", "<leader>o", ":TestePick<cr>", { silent = true })
-- vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
-- 	pattern = "*",
-- 	callback = function()
-- 		if vim.opt.buftype:get() == "terminal" then vim.cmd("startinsert") end
-- 	end,
-- })

-- vim.api.nvim_create_user_command("FilePickModified", function(opts)
-- 	if vim.tbl_count(opts.fargs) == 0 then return end
-- 	vim.cmd.edit({ args = opts.fargs })
-- end, {
-- 	complete = function()
-- 		local cmd = "git status --short | awk '{$1=\"\"; print $0}'"
-- 		return vim.split(vim.trim(io.popen(cmd):read("*a")), "\n")
-- 	end,
-- 	force = true,
-- 	nargs = "*",
-- })
-- vim.keymap.set("n", "<leader>gs", function()
-- 	local keys = vim.api.nvim_replace_termcodes(":FilePickModified <tab>", true, false, true)
-- 	vim.api.nvim_input(keys)
-- end)

-- vim.keymap.set("n", "<leader>e", ":Ex<cr>", { silent = true })
-- vim.g.netrw_altfile = 1
-- vim.g.netrw_banner = 0
-- vim.api.nvim_create_autocmd({ "FileType" }, {
-- 	group = vim.api.nvim_create_augroup("custom_netrw", { clear = true }),
-- 	pattern = "netrw",
-- 	callback = function()
-- 		vim.keymap.set("n", "<tab>", ":bwipeout<cr>", { buffer = true, remap = true })
-- 		vim.keymap.set("n", "h", "-^", { buffer = true, remap = true })
-- 		vim.keymap.set("n", "l", "<cr>", { buffer = true, remap = true })
-- 	end,
-- })
--
-- vim.keymap.set("n", "<leader><tab>", function()
-- 	local keys = vim.api.nvim_replace_termcodes(":b<tab> ", true, false, true)
-- 	vim.api.nvim_input(keys)
-- end)
--
-- _G.custom_status = {
-- 	modified = function() return vim.bo.modified and "changed" or "" end,
-- 	path = function()
-- 		local path = vim.fn.expand("%") or ""
-- 		if path == "" then return "" end
-- 		return "./" .. path
-- 	end,
-- 	diagnostics = function()
-- 		local get = vim.diagnostic.get
-- 		local severity = vim.diagnostic.severity
-- 		local levels = {
-- 			{ count = #get(0, { severity = severity.ERROR }), label = "%#DiagnosticSignError# " },
-- 			{ count = #get(0, { severity = severity.WARN }), label = "%#DiagnosticSignWarn# " },
-- 			{ count = #get(0, { severity = severity.INFO }), label = "%#DiagnosticSignInfo# " },
-- 			{ count = #get(0, { severity = severity.HINT }), label = "%#DiagnosticSignHint# " },
-- 		}
-- 		local diagnostics = "  "
-- 		for _, level in ipairs(levels) do
-- 			if level.count > 0 then diagnostics = diagnostics .. level.label .. level.count .. " " end
-- 		end
-- 		return diagnostics:sub(1, -2)
-- 	end,
-- 	branch = function()
-- 		local branch = vim.fn.system("git branch --show-current 2>/dev/null")
-- 		return branch ~= "" and branch:gsub("\n", "") or ""
-- 	end,
-- }
--
-- vim.o.statusline = table.concat({
-- 	"%#LineNr#",
-- 	"%{%v:lua.custom_status.path()%}",
-- 	" ",
-- 	"%#Bold#",
-- 	"%{%v:lua.custom_status.modified()%}",
-- 	" ",
-- 	"%{%v:lua.custom_status.diagnostics()%}",
-- 	" ",
-- 	"%=",
-- 	"%#LineNr#",
-- 	"%{&filetype}",
-- 	" ",
-- 	"%#CursorLineNr#",
-- 	"%{%v:lua.custom_status.branch()%}",
-- 	" ",
-- 	"%#LineNr#",
-- 	"%l:%-c %p%%",
-- }, "")

-- -- user commands
-- local cmd_palette = {
-- 	{ "lazy", "Lazy", "Open Lazy dialog" },
-- 	{ "mason", "Mason", "Open Mason dialog" },
-- 	{ "reload", "cq", "Reload Neovim" },
-- 	{ "sync", "Lazy sync", "Synchronize Lazy plugins" },
-- }
-- vim.api.nvim_create_user_command("MyCommand", function(opts)
-- 	for _, cmd in ipairs(cmd_palette) do
-- 		local input = opts.fargs[1]:match("^[^%s]+")
-- 		if input and input:lower() == cmd[1]:lower() then
-- 			vim.cmd(cmd[2])
-- 			return
-- 		end
-- 	end
-- end, {
-- 	complete = function()
-- 		local result = {}
-- 		local max_len = 0
-- 		for _, subtable in ipairs(cmd_palette) do
-- 			if subtable[1] then max_len = math.max(max_len, #subtable[1]) end
-- 		end
-- 		for _, subtable in ipairs(cmd_palette) do
-- 			if subtable[1] then
-- 				local padded = string.format("%-" .. max_len .. "s - %s", subtable[1], subtable[3])
-- 				table.insert(result, padded)
-- 			end
-- 		end
-- 		return result
-- 	end,
-- 	nargs = 1,
-- })
-- vim.keymap.set("n", "<leader><enter>", function()
-- 	local keys = vim.api.nvim_replace_termcodes(":MyCommand<tab> ", true, false, true)
-- 	vim.api.nvim_input(keys)
-- end)

-- vim.opt.path:append("**")
-- vim.opt.wildmenu = true

--

-- adds custom color palette
local custom_black = "#2e3440"
local custom_red = "#ff3242"
local custom_green = "#44bc44"
local custom_yellow = "#ff9400"
local custom_blue = "#0883ff"
local custom_magenta = "#d930d9"
local custom_cyan = "#00d8eb"
local custom_white = "#d8dee9"
local custom_bright_black = "#4c566a"
local custom_bright_red = "#ff6e6e"
local custom_bright_green = "#9ec875"
local custom_bright_yellow = "#ffaf00"
local custom_bright_blue = "#47bfe6"
local custom_bright_magenta = "#d294ff"
local custom_bright_cyan = "#8ae2f0"
local custom_bright_white = "#eceff4"
local custom_background = "#000000"
local custom_foreground = "#d2d1e6"
-- configures colorscheme
vim.cmd.highlight("clear")
for hl_group, attrs in pairs(vim.api.nvim_get_hl(0, {})) do
	if attrs.bg then attrs.bg = custom_background end
	if attrs.fg then attrs.fg = custom_foreground end
	vim.api.nvim_set_hl(0, hl_group, attrs)
end

vim.api.nvim_set_hl(0, "Constant", { fg = custom_bright_white, bold = true })
vim.api.nvim_set_hl(0, "String", { fg = custom_bright_white, bold = true })
-- vim.api.nvim_set_hl(0, "Statement", { fg = custom_bright_white, bold = true, italic = true })
-- vim.api.nvim_set_hl(0, "Function", { fg = custom_bright_black, italic = true })

vim.api.nvim_set_hl(0, "CurSearch", { bg = custom_white, fg = custom_black, bold = true })
vim.api.nvim_set_hl(0, "IncSearch", { bg = custom_white, fg = custom_black, bold = true })
vim.api.nvim_set_hl(0, "Search", { bg = custom_black })

vim.api.nvim_set_hl(0, "Comment", { fg = custom_bright_black, italic = true })
vim.api.nvim_set_hl(0, "CursorLine", { bg = custom_black })
vim.api.nvim_set_hl(0, "LineNr", { fg = custom_bright_black })
vim.api.nvim_set_hl(0, "Visual", { bg = custom_white, fg = custom_black, bold = true })

vim.api.nvim_set_hl(0, "DiagnosticError", { fg = custom_red, underline = true })
vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = custom_yellow, underline = true })
vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = custom_cyan, underline = true })
vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = custom_white, underline = true })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { fg = custom_red, underline = true })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { fg = custom_yellow, underline = true })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { fg = custom_cyan, underline = true })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { fg = custom_white, underline = true })
