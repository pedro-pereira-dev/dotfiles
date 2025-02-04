---@diagnostic disable: undefined-global
-- globals
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- appearance
vim.opt.colorcolumn = "80,100,120"
vim.opt.cursorline = true
vim.opt.scrolloff = 15
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
-- panes direction
vim.opt.splitbelow = true
vim.opt.splitright = true
-- line numbers
vim.opt.number = true
vim.opt.numberwidth = 5
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

-- custom commands
vim.keymap.set("n", "<leader><tab>", ":FzfLua buffers<cr>", { silent = true, desc = "List open buffers" })
vim.keymap.set("n", "<leader>e", ":OilOpen<cr>", { silent = true, desc = "Open Oil" })
vim.keymap.set("n", "<leader>f", ":FzfLua live_grep resume=true<cr>", { silent = true, desc = "Search word" })
vim.keymap.set("n", "<leader>cl", ":Lazy<cr>", { silent = true, desc = "Open Lazy" })
vim.keymap.set("n", "<leader>cm", ":Mason<cr>", { silent = true, desc = "Open Mason" })
vim.keymap.set("n", "<leader>o", ":FzfLua files<cr>", { silent = true, desc = "Search file" })
vim.keymap.set("n", "<leader>q", ":QuitBuffer<cr>", { silent = true, desc = "Close current buffer" })
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
vim.keymap.set("n", "<leader>h", "<c-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<leader>j", "<c-w>j", { desc = "Go to down window" })
vim.keymap.set("n", "<leader>k", "<c-w>k", { desc = "Go to up window" })
vim.keymap.set("n", "<leader>l", "<c-w>l", { desc = "Go to right window" })
-- clipboard manipulation
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste from clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
-- selection movement
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { silent = true, desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { silent = true, desc = "Move selection up" })

-- bufferline
vim.keymap.set("n", "<leader>1", ":BufferLineGoToBuffer 1<cr>", { silent = true, desc = "Go to buffer 1" })
vim.keymap.set("n", "<leader>2", ":BufferLineGoToBuffer 2<cr>", { silent = true, desc = "Go to buffer 2" })
vim.keymap.set("n", "<leader>3", ":BufferLineGoToBuffer 3<cr>", { silent = true, desc = "Go to buffer 3" })
vim.keymap.set("n", "<leader>4", ":BufferLineGoToBuffer 4<cr>", { silent = true, desc = "Go to buffer 4" })
vim.keymap.set("n", "<leader>5", ":BufferLineGoToBuffer 5<cr>", { silent = true, desc = "Go to buffer 5" })
vim.keymap.set("n", "<leader>6", ":BufferLineGoToBuffer 6<cr>", { silent = true, desc = "Go to buffer 6" })
vim.keymap.set("n", "<leader>7", ":BufferLineGoToBuffer 7<cr>", { silent = true, desc = "Go to buffer 7" })
vim.keymap.set("n", "<leader>8", ":BufferLineGoToBuffer 8<cr>", { silent = true, desc = "Go to buffer 8" })
vim.keymap.set("n", "<leader>9", ":BufferLineGoToBuffer 9<cr>", { silent = true, desc = "Go to buffer 9" })

local language_servers = {
	bashls = {}, -- sh / bash
	jsonls = {}, -- json
	lua_ls = {}, -- lua
	volar = { init_options = { vue = { hybridMode = false } } }, -- vue
	vtsls = {}, -- vue typescript
}

local language_formatters = {
	json = { "prettier" }, -- json
	lua = { "stylua" }, -- lua
	sh = { "shfmt" }, -- sh / bash
	vue = { "prettier" }, -- vue
}

local language_linters = {
	"jsonlint", -- json
	"luacheck", -- lua
	"shellcheck", -- sh / bash
}

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("custom_highlight_yank", { clear = true }),
	callback = function()
		(vim.hl or vim.highlight).on_yank()
	end,
})

local function list_formatters(formatters)
	local formatters_list = {}
	for _, option in pairs(formatters) do
		for _, formatter in pairs(option) do
			if type(formatter) == "string" then
				table.insert(formatters_list, formatter)
			end
		end
	end
	return formatters_list
end

local language_tools = {}
vim.list_extend(language_tools, vim.tbl_keys(language_servers or {}))
vim.list_extend(language_tools, list_formatters(language_formatters))
vim.list_extend(language_tools, language_linters)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({

	-- https://lazy.folke.io/configuration
	checker = { enabled = true },
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				-- "matchit",
				-- "matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
	ui = { border = "single", size = { width = 100 } },
	spec = {

		-- colorscheme
		{
			"rebelot/kanagawa.nvim",
			priority = 1000,
			opts = {
				keywordStyle = { bold = true, italic = false },
				statementStyle = { bold = false },
				typeStyle = { italic = true },
				transparent = true,
				colors = { theme = { all = { ui = { bg_gutter = "none" } } } },
				overrides = function(colors)
					local style = { bg = "none", fg = colors.theme.ui.fg }
					return { FloatBorder = style, NormalFloat = style }
				end,
			},
			init = function()
				vim.cmd.colorscheme("kanagawa")
			end,
		},

		-- startup page
		{
			"nvimdev/dashboard-nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			event = { "VimEnter" },
			opts = {
				config = {
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
					shortcut = {
						{ key = "s", group = "fg", action = "Lazy sync", desc = "󰒲 Sync" },
						{ key = "m", group = "fg", action = "Mason", desc = " Mason" },
						{ key = "q", group = "fg", action = "cq", desc = " Reload" },
					},
					project = { enable = false },
					mru = { enable = false },
					footer = {
						"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
						"",
						"pedro-pereira-dev | https://github.com/pedro-pereira-dev",
					},
				},
			},
		},

		-- lsp
		{
			"neovim/nvim-lspconfig",
			dependencies = {
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				"hrsh7th/cmp-nvim-lsp",
				"williamboman/mason-lspconfig.nvim",
				"williamboman/mason.nvim",
			},
			cmd = { "Mason" },
			event = { "BufNewFile", "BufReadPre" },
			config = function()
				local default_capabilities = require("cmp_nvim_lsp").default_capabilities()
				local capabilities = vim.lsp.protocol.make_client_capabilities()
				capabilities = vim.tbl_deep_extend("force", capabilities, default_capabilities)
				local default_handler = {
					function(server_name)
						local server = language_servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				}

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

				require("mason-tool-installer").setup({ auto_update = true, ensure_installed = language_tools })
				---@diagnostic disable-next-line: missing-fields
				require("mason").setup({ ui = { border = "single", width = 100 } })
				---@diagnostic disable-next-line: missing-fields
				require("mason-lspconfig").setup({ handlers = default_handler })
				require("mason-tool-installer").run_on_start()
			end,
		},

		-- autocompletion
		{
			"hrsh7th/nvim-cmp",
			event = { "InsertEnter" },
			config = function()
				local border = { border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" } }
				local cmp = require("cmp")
				cmp.setup({
					snippet = {
						expand = function(args)
							vim.snippet.expand(args.body)
						end,
					},
					window = {
						completion = cmp.config.window.bordered(border),
						documentation = cmp.config.window.bordered(border),
					},
					mapping = cmp.mapping.preset.insert({
						["<c-space>"] = cmp.mapping.complete(),
						["<cr>"] = cmp.mapping.confirm({ select = true }),
						["<s-tab>"] = cmp.mapping.select_prev_item(),
						["<tab>"] = cmp.mapping.select_next_item(),
					}),
					sources = cmp.config.sources(
						{ { name = "lazydev", group_index = 0 }, { name = "nvim_lsp" } },
						{ { name = "buffer" } }
					),
				})
			end,
		},

		-- autoformat
		{
			"stevearc/conform.nvim",
			cmd = { "SaveWithoutFormatter" },
			event = { "BufWritePre" },
			config = function()
				require("conform").setup({
					default_format_opts = { lsp_format = "fallback" },
					formatters_by_ft = language_formatters,
					format_on_save = function(bufnr)
						if vim.b[bufnr].disable_autoformat then
							return
						end
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
						if ok and stats and stats.size > max_filesize then
							return true
						end
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

		-- file explorer
		{
			"stevearc/oil.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			cmd = { "Oil" },
			opts = {
				constrain_cursor = "name",
				watch_for_changes = true,
				keymaps = {
					["<bs>"] = { "actions.parent", mode = "n" },
					["<cr>"] = { "actions.select", mode = "n" },
					["e"] = { "actions.open_cwd", mode = "n" },
					["h"] = { "actions.parent", mode = "n" },
					["l"] = { "actions.select", mode = "n" },
				},
				use_default_keymaps = false,
				view_options = { show_hidden = true },
			},
			init = function()
				vim.api.nvim_create_user_command("OilOpen", function()
					require("oil").open(nil, { preview = { vertical = true } })
				end, { desc = "Open Oil with preview" })
			end,
		},

		-- fuzzy finder
		{
			"ibhagwan/fzf-lua",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			cmd = { "FzfLua", "FzfLuaChangeProject" },
			config = function()
				local fzf_lua = require("fzf-lua")
				local fzf_actions = require("fzf-lua.actions")
				fzf_lua.setup({
					{ "default-title" },

					-- configurations
					winopts = {
						border = "single",
						preview = { layout = "vertical", vertical = "down:70%", wrap = "wrap" },
						width = 100,
					},
					keymap = {
						builtin = {
							["<C-j>"] = "down",
							["<C-k>"] = "up",
							["<S-down>"] = "preview-page-down",
							["<S-j>"] = "preview-page-down",
							["<S-k>"] = "preview-page-up",
							["<S-up>"] = "preview-page-up",
						},
						fzf = {
							["ctrl-space"] = "toggle",
							["shift-tab"] = "up",
							["tab"] = "down",
						},
					},
					actions = { files = { ["enter"] = fzf_actions.file_edit } },
					fzf_opts = { ["--cycle"] = true },
					fzf_colors = true,

					-- pickers
					files = { cwd_prompt = false, git_icons = false, actions = { ["ctrl-g"] = false } },
					git = {
						branches = {
							actions = {
								["ctrl-d"] = { fn = fzf_actions.git_branch_del, reload = true },
								["ctrl-x"] = false,
							},
							cmd_add = { "git", "checkout", "-b" },
							cmd_del = { "git", "branch", "--delete", "--force" },
						},
					},
					grep = {
						cmd = "rg --hidden --column --smart-case --color=always",
						actions = { ["ctrl-g"] = false },
					},
					buffers = {
						actions = {
							["ctrl-d"] = { fn = fzf_actions.buf_del, reload = true },
							["ctrl-x"] = false,
						},
					},
					keymaps = { previewer = false },
				})

				vim.api.nvim_create_user_command("FzfLuaChangeProject", function()
					local cmd = "find "
						.. vim.env.HOME
						.. ' -type d -name ".git" -not -path "*/.*/*" -print0 | xargs -0 -I {} dirname {}'
					fzf_lua.fzf_exec(cmd, {
						actions = {
							["enter"] = {
								fn = function(selected)
									vim.fn.system("tmux-sessionixidizer " .. selected[1])
								end,
							},
						},
					})
				end, { desc = "Change project" })
			end,
		},

		-- status bar
		-- {
		-- 	"nvim-lualine/lualine.nvim",
		-- 	dependencies = { "nvim-tree/nvim-web-devicons" },
		-- 	event = { "BufReadPre", "BufNewFile" },
		-- 	opts = {
		-- 		options = {
		-- 			icons_enabled = true,
		-- 			theme = "auto",
		-- 			component_separators = { left = "", right = "" },
		-- 			section_separators = { left = "", right = "" },
		-- 			disabled_filetypes = {
		-- 				statusline = { "NvimTree" },
		-- 				winbar = {},
		-- 			},
		-- 			ignore_focus = {},
		-- 			always_divide_middle = true,
		-- 			always_show_tabline = true,
		-- 			globalstatus = false,
		-- 			refresh = {
		-- 				statusline = 100,
		-- 				tabline = 100,
		-- 				winbar = 100,
		-- 			},
		-- 		},
		-- 		sections = {
		-- 			lualine_a = { "mode" },
		-- 			lualine_b = { "branch", "diff", "diagnostics" },
		-- 			lualine_c = { "filename" },
		-- 			lualine_x = { "encoding", "fileformat", "filetype" },
		-- 			lualine_y = { "progress" },
		-- 			lualine_z = { "location" },
		-- 		},
		-- 		inactive_sections = {
		-- 			lualine_a = {},
		-- 			lualine_b = {},
		-- 			lualine_c = { "filename" },
		-- 			lualine_x = { "location" },
		-- 			lualine_y = {},
		-- 			lualine_z = {},
		-- 		},
		-- 		tabline = {},
		-- 		winbar = {
		-- 			-- lualine_a = { "buffers" },
		-- 			lualine_a = {},
		-- 			lualine_b = {},
		-- 			lualine_c = {},
		-- 			lualine_x = {},
		-- 			lualine_y = {},
		-- 			lualine_z = {},
		-- 		},
		-- 		inactive_winbar = {},
		-- 		extensions = {},
		-- 	},
		-- },

		-- top bar
		-- {
		-- 	"akinsho/bufferline.nvim",
		-- 	dependencies = { "nvim-tree/nvim-web-devicons" },
		-- 	-- event = { "BufNewFile", "BufReadPre" },
		-- 	lazy = false,
		-- 	opts = {
		-- 		options = {
		-- 			offsets = {
		-- 				{
		-- 					filetype = "NvimTree",
		-- 					text = function()
		-- 						return vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. "/"
		-- 					end,
		-- 				},
		-- 			},
		-- 		},
		-- 	},
		-- },

		-- other plugins
	},
})
