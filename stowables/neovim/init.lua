---@diagnostic disable: undefined-global
-- globals
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- appearance
vim.opt.colorcolumn = "80,100,120"
vim.opt.cursorline = true
vim.opt.scrolloff = 15
-- line numbers
vim.opt.number = true
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
vim.keymap.set("n", "<leader>?", ":FzfLua keymaps<cr>", { silent = true, desc = "List available keymaps" })
vim.keymap.set("n", "<leader>cl", ":Lazy<cr>", { silent = true, desc = "Open Lazy" })
vim.keymap.set("n", "<leader>cm", ":Mason<cr>", { silent = true, desc = "Open Mason" })
vim.keymap.set("n", "<leader>fw", ":FzfLua live_grep<cr>", { silent = true, desc = "Search word" })
vim.keymap.set("n", "<leader>gb", ":FzfLua git_branches<cr>", { silent = true, desc = "List git branches" })
vim.keymap.set("n", "<leader>o", ":FzfLua files<cr>", { silent = true, desc = "Search file" })
vim.keymap.set("n", "<leader>q", ":bd!<cr>", { silent = true, desc = "Quit current buffer" })
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
vim.keymap.set("n", "<c-h>", "<c-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<c-j>", "<c-w>j", { desc = "Go to down window" })
vim.keymap.set("n", "<c-k>", "<c-w>k", { desc = "Go to up window" })
vim.keymap.set("n", "<c-l>", "<c-w>l", { desc = "Go to right window" })
-- clipboard manipulation
vim.keymap.set({ "n", "v" }, "<leader>cp", [["+p]], { desc = "Paste from clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>cy", [["+y]], { desc = "Yank to clipboard" })
-- selection movement
vim.keymap.set("i", "<a-j>", "<esc>:m .+1<cr>==gi", { silent = true, desc = "Move selection down" })
vim.keymap.set("i", "<a-k>", "<esc>:m .-2<cr>==gi", { silent = true, desc = "Move selection up" })
vim.keymap.set("n", "<a-j>", ":execute 'move .+' . v:count1<cr>==", { silent = true, desc = "Move selection down" })
vim.keymap.set("n", "<a-k>", ":execute 'move .-' . (v:count1 + 1)<cr>==", { silent = true, desc = "Move selection up" })
vim.keymap.set(
	"v",
	"<a-j>",
	":<c-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv",
	{ silent = true, desc = "Move selection down" }
)
vim.keymap.set(
	"v",
	"<a-k>",
	":<c-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv",
	{ silent = true, desc = "Move selection up" }
)

local lsp_tools = { "stylua" }
local lsp_servers = { lua_ls = {} }
local conform_formatters = { lua = { "stylua" } }

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("custom_highlight_yank", { clear = true }),
	callback = function()
		(vim.hl or vim.highlight).on_yank()
	end,
})

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
				-- "netrwPlugin",
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
			"catppuccin/nvim",
			name = "catppuccin.nvim",
			priority = 1000,
			opts = {
				color_overrides = {
					mocha = {
						base = "#000000",
						mantle = "#000000",
						crust = "#000000",
					},
				},
			},
			init = function()
				vim.cmd.colorscheme("catppuccin")
			end,
		},

		-- lsp
		{
			"neovim/nvim-lspconfig",
			cmd = { "Mason", "LspInfo", "LspInstall", "LspStart" },
			event = { "BufReadPre", "BufNewFile" },
			dependencies = {
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				"hrsh7th/cmp-nvim-lsp",
				"williamboman/mason-lspconfig.nvim",
				"williamboman/mason.nvim",
			},
			config = function()
				local default_capabilities = require("cmp_nvim_lsp").default_capabilities()
				local capabilities = vim.lsp.protocol.make_client_capabilities()
				capabilities = vim.tbl_deep_extend("force", capabilities, default_capabilities)

				local installed_tools = vim.tbl_keys(lsp_servers or {})
				vim.list_extend(installed_tools, lsp_tools)

				local default_handler = {
					function(server_name)
						local server = lsp_servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				}

				require("mason-tool-installer").setup({ auto_update = true, ensure_installed = installed_tools })
				---@diagnostic disable-next-line: missing-fields
				require("mason").setup({ ui = { border = "single", width = 100 } })
				---@diagnostic disable-next-line: missing-fields
				require("mason-lspconfig").setup({ handlers = default_handler })
				require("mason-tool-installer").run_on_start()
			end,
		},

		-- fuzzy finder
		{
			"ibhagwan/fzf-lua",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			cmd = "FzfLua",
			opts = function()
				local actions = require("fzf-lua.actions")
				return {
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
					actions = { files = { ["enter"] = actions.file_edit } },
					fzf_opts = { ["--cycle"] = true },
					fzf_colors = true,

					-- pickers
					files = { cwd_prompt = false, git_icons = false, actions = { ["ctrl-g"] = false } },
					git = {
						branches = {
							actions = {
								["ctrl-d"] = { fn = actions.git_branch_del, reload = true },
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
							["ctrl-d"] = { fn = actions.buf_del, reload = true },
							["ctrl-x"] = false,
						},
					},
					keymaps = { previewer = false },
				}
			end,
		},

		-- autoformat
		{
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			cmd = "SaveWithoutFormatter",
			opts = {
				default_format_opts = { lsp_format = "fallback" },
				formatters_by_ft = conform_formatters,
				format_on_save = function(bufnr)
					if vim.b[bufnr].disable_autoformat then
						return
					end
					return { lsp_format = "fallback", timeout_ms = 500 }
				end,
			},
			init = function()
				vim.api.nvim_create_user_command("SaveWithoutFormatter", function()
					vim.b.disable_autoformat = true
					vim.cmd.write()
					vim.b.disable_autoformat = false
				end, { desc = "Save document without format" })
			end,
		},

		-- TODO: continue this configuration

		-- local language_highlights = { "lua" }
		-- -- treesitter
		-- {
		-- 	"nvim-treesitter/nvim-treesitter",
		-- 	build = ":TSUpdate",
		-- 	event = { "BufReadPre", "BufNewFile" },
		-- 	main = "nvim-treesitter.configs",
		-- 	opts = {
		-- 		ensure_installed = language_highlights,
		-- 		highlight = {
		-- 			enable = true,
		-- 			disable = function(_, buf)
		-- 				local max_filesize = 100 * 1024 -- 100 KB
		-- 				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
		-- 				if ok and stats and stats.size > max_filesize then
		-- 					return true
		-- 				end
		-- 			end,
		-- 		},
		-- 		incremental_selection = { enable = true },
		-- 		indent = { enable = true },
		-- 	},
		-- 	init = function(plugin)
		-- 		require("lazy.core.loader").add_to_rtp(plugin)
		-- 		require("nvim-treesitter.query_predicates")
		-- 	end,
		-- },

		-- autocompletion
		{
			"hrsh7th/nvim-cmp",
			event = "InsertEnter",
			config = function()
				local cmp = require("cmp")
				cmp.setup({
					sources = {
						{ name = "lazydev", group_index = 0 },
						{ name = "nvim_lsp" },
					},
					mapping = cmp.mapping.preset.insert({
						["<C-Space>"] = cmp.mapping.complete(),
						["<C-u>"] = cmp.mapping.scroll_docs(-4),
						["<C-d>"] = cmp.mapping.scroll_docs(4),
					}),
					snippet = {
						expand = function(args)
							vim.snippet.expand(args.body)
						end,
					},
				})
			end,
		},

		-- TODO: other plugins...
	},
})
