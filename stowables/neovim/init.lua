---@diagnostic disable: undefined-global
-- globals
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- appearance
vim.opt.colorcolumn = "80,100,120"
vim.opt.cursorline = true
vim.opt.laststatus = 0
vim.opt.ruler = false
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

-- WIP
vim.keymap.set({ "n", "v" }, "H", "0^") -- "beginning of line"
vim.keymap.set({ "n", "v" }, "L", "$") --"end of line" ,
vim.keymap.set("t", "<m-esc>", "<c-\\><c-n>", { desc = "Exit terminal mode" })
-- WIP

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

local language_servers = {
	bashls = {}, -- sh / bash
	jsonls = {}, -- json
	lua_ls = {}, -- lua
	volar = { init_options = { vue = { hybridMode = false } } }, -- vue
	vtsls = {}, -- vue typescript
}

local language_formatters = {
	json = { "prettier" },
	lua = { "stylua" },
	sh = { "shfmt" },
	typescript = { "prettier" },
	vue = { "prettier" },
}

local language_linters = {
	"jsonlint", -- json
	"luacheck", -- lua
	"shellcheck", -- sh / bash
}

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	group = vim.api.nvim_create_augroup("custom_highlight_yank", { clear = true }),
	callback = function()
		(vim.hl or vim.highlight).on_yank()
	end,
})

_G.custom_status = {
	modified = function()
		return vim.bo.modified and "󰛸 " or "  "
	end,
	path = function()
		local path = vim.fn.expand("%") or ""
		if path == "" then
			return ""
		end
		return "./" .. path
	end,
	diagnostics = function()
		local levels = vim.diagnostic.severity
		local errors = #vim.diagnostic.get(0, { severity = levels.ERROR })
		local warnings = #vim.diagnostic.get(0, { severity = levels.WARN })
		local infos = #vim.diagnostic.get(0, { severity = levels.INFO })
		local hints = #vim.diagnostic.get(0, { severity = levels.HINT })
		return table.concat({
			errors > 0 and "%#DiagnosticSignError# " .. errors or "",
			warnings > 0 and "%#DiagnosticSignWarn# " .. warnings or "",
			infos > 0 and "%#DiagnosticSignInfo# " .. infos or "",
			hints > 0 and "%#DiagnosticSignHint# " .. hints or "",
			"%#Bold#",
		}, " ")
	end,
	branch = function()
		local branch = vim.fn.system("git branch --show-current 2>/dev/null")
		return branch ~= "" and branch:gsub("\n", "") or ""
	end,
}

vim.o.winbar = table.concat({
	"%#Bold#%t",
	" %#RenderMarkdownH4Fg#%{%v:lua.custom_status.modified()%}",
	"%#LineNr#%{%v:lua.custom_status.path()%}",
	"  %{%v:lua.custom_status.diagnostics()%}",
	"%=",
	"%#Bold#" .. vim.fn.fnamemodify(vim.fn.expand("%:p:~:h"), ":t"),
	"  %#CursorLineNr#%{%v:lua.custom_status.branch()%}",
	"   %#LineNr#%{&filetype}",
	"  %#LineNr#%4l,%-3c",
	" %#Bold#%3p%%",
}, "")

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
			"idr4n/github-monochrome.nvim",
			priority = 1000,
			opts = {
				transparent = true,
				styles = { floats = "transparent" },
				on_highlights = function(hl, c)
					local util = require("github-monochrome.util")
					hl.DiagnosticUnderlineError = { bg = util.blend(c.error, 0.25, util.bg), fg = c.error }
					hl.DiagnosticUnderlineHint = { bg = util.blend(c.hint, 0.25, util.bg), fg = c.hint }
					hl.DiagnosticUnderlineInfo = { bg = util.blend(c.info, 0.25, util.bg), fg = c.info }
					hl.DiagnosticUnderlineWarn = { bg = util.blend(c.warning, 0.25, util.bg), fg = c.warning }
					hl.FloatBorder = { fg = c.fg }
				end,
			},
			init = function()
				vim.cmd.colorscheme("github-monochrome-rosepine")
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
						"pedro-pereira-dev | https://pedro-pereira-dev.github.io",
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

		-- other plugins ...
	},
})
