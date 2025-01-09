---@diagnostic disable: undefined-global
-- globals
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- appearance
vim.opt.colorcolumn = "80,100,120"
vim.opt.cursorline = true
vim.opt.scrolloff = 15
vim.opt.signcolumn = "yes"
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
vim.keymap.set("n", "<leader>1", ":LualineBuffersJump 1<cr>", { silent = true, desc = "Open buffer 1" })
vim.keymap.set("n", "<leader>2", ":LualineBuffersJump 2<cr>", { silent = true, desc = "Open buffer 2" })
vim.keymap.set("n", "<leader>3", ":LualineBuffersJump 3<cr>", { silent = true, desc = "Open buffer 3" })
vim.keymap.set("n", "<leader>4", ":LualineBuffersJump 4<cr>", { silent = true, desc = "Open buffer 4" })
vim.keymap.set("n", "<leader>5", ":LualineBuffersJump 5<cr>", { silent = true, desc = "Open buffer 5" })
vim.keymap.set("n", "<leader>6", ":LualineBuffersJump 6<cr>", { silent = true, desc = "Open buffer 6" })
vim.keymap.set("n", "<leader>7", ":LualineBuffersJump 7<cr>", { silent = true, desc = "Open buffer 7" })
vim.keymap.set("n", "<leader>8", ":LualineBuffersJump 8<cr>", { silent = true, desc = "Open buffer 8" })
vim.keymap.set("n", "<leader>9", ":LualineBuffersJump 9<cr>", { silent = true, desc = "Open buffer 9" })
vim.keymap.set("n", "<leader><tab>", ":FzfLua buffers<cr>", { silent = true, desc = "List open buffers" })
vim.keymap.set("n", "<leader>?", ":FzfLua keymaps<cr>", { silent = true, desc = "List available keymaps" })
vim.keymap.set("n", "<leader>E", ":Oil<cr>", { desc = "Open Oil" })
vim.keymap.set("n", "<leader>F", ":FzfLua live_grep resume=true<cr>", { silent = true, desc = "Search word - resume" })
vim.keymap.set("n", "<leader>O", ":FzfLua files resume=true<cr>", { silent = true, desc = "Search file - resume" })
vim.keymap.set("n", "<leader>cl", ":Lazy<cr>", { silent = true, desc = "Open Lazy" })
vim.keymap.set("n", "<leader>cm", ":Mason<cr>", { silent = true, desc = "Open Mason" })
vim.keymap.set("n", "<leader>e", ":NvimTreeFindFile<cr>", { desc = "Open NvimTree" })
vim.keymap.set("n", "<leader>f", ":FzfLua live_grep<cr>", { silent = true, desc = "Search word" })
vim.keymap.set("n", "<leader>gb", ":FzfLua git_branches<cr>", { silent = true, desc = "List git branches" })
vim.keymap.set("n", "<leader>o", ":FzfLua files<cr>", { silent = true, desc = "Search file" })
vim.keymap.set("n", "<leader>q", ":QuitBuffer<cr>", { silent = true, desc = "Quit current buffer" })
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

		-- startup page
		{
			"nvimdev/dashboard-nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			event = { "VimEnter" },
			opts = function()
				local git_remote_url = vim.fn
					.system("git config --get remote.origin.url")
					:gsub("\n", "")
					:gsub("(.-)%.git$", "%1")
					:gsub("git@([^:]+):", "https://%1/")
				return {
					shortcut_type = "number",
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
							"" .. git_remote_url:match("/([^/]+)$") .. " | " .. git_remote_url,
							"",
						},
						shortcut = {
							{ desc = "󰍉 Files", group = "DiagnosticError", action = "FzfLua files", key = "o" },
							{ desc = "󰍉 Projects", group = "Number", action = "FzfLuaChangeProject", key = "p" },
							{ desc = "󰒲 Lazy", group = "DiagnosticWarn", action = "Lazy", key = "l" },
							{ desc = "󰒲 Lazy Sync", group = "DiagnosticHint", action = "Lazy sync", key = "s" },
							{ desc = " Mason", group = "Label", action = "Mason", key = "m" },
							{ desc = " Reload", group = "@property", action = "cq", key = "q" },
						},
						project = { enable = false },
						mru = { limit = 9, label = "Recent Files", cwd_only = true },
						footer = {
							"",
							"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
							"",
							"pedro-pereira-dev | https://github.com/pedro-pereira-dev",
						},
					},
				}
			end,
		},

		-- buffer deletion util
		{
			"echasnovski/mini.bufremove",
			cmd = { "QuitBuffer" },
			config = function()
				vim.api.nvim_create_user_command("QuitBuffer", function()
					require("mini.bufremove").delete()
				end, { desc = "Quit buffer preserving window layout" })
			end,
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

				require("mason-tool-installer").setup({ auto_update = true, ensure_installed = language_tools })
				---@diagnostic disable-next-line: missing-fields
				require("mason").setup({ ui = { border = "single", width = 100 } })
				---@diagnostic disable-next-line: missing-fields
				require("mason-lspconfig").setup({ handlers = default_handler })
				require("mason-tool-installer").run_on_start()
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

				vim.api.nvim_create_user_command("SaveWithoutFormatter", function()
					vim.b.disable_autoformat = true
					vim.cmd.write()
					vim.b.disable_autoformat = false
				end, { desc = "Save document without format" })
			end,
		},

		-- file tree
		{
			"nvim-tree/nvim-tree.lua",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			event = { "BufNewFile", "BufReadPre" },
			config = function()
				local tree = require("nvim-tree")
				local api = require("nvim-tree.api")
				local function my_on_attach(bufnr)
					local function opts(desc)
						return {
							desc = "nvim-tree: " .. desc,
							buffer = bufnr,
							noremap = true,
							silent = true,
							nowait = true,
						}
					end

					vim.keymap.set("n", "<cr>", api.node.open.edit, opts("Open File"))
					vim.keymap.set("n", "<leader>E", api.tree.collapse_all, opts("Collapse All"))
					vim.keymap.set("n", "<leader>e", "<c-w>l", opts("Focus Editor"))
					vim.keymap.set("n", "<leader>f", api.tree.search_node, opts("Find File"))
					vim.keymap.set("n", "<leader>q", api.tree.close, opts("Close Tree"))
					vim.keymap.set("n", "<leader>s", api.tree.search_node, opts("Find File"))
					vim.keymap.set("n", "?", api.tree.toggle_help, opts("Show Help"))
					vim.keymap.set("n", "A", api.fs.create, opts("Create File Or Directory"))
					vim.keymap.set("n", "E", api.tree.collapse_all, opts("Collapse All"))
					vim.keymap.set("n", "H", api.node.navigate.parent_close, opts("Close Directory"))
					vim.keymap.set("n", "I", api.fs.create, opts("Create File Or Directory"))
					vim.keymap.set("n", "O", api.fs.create, opts("Create File Or Directory"))
					vim.keymap.set("n", "Y", api.fs.copy.relative_path, opts("Copy Relative Path"))
					vim.keymap.set("n", "a", api.fs.create, opts("Create File Or Directory"))
					vim.keymap.set("n", "c", api.fs.rename, opts("Rename File"))
					vim.keymap.set("n", "d", api.fs.cut, opts("Cut File"))
					vim.keymap.set("n", "f", api.tree.search_node, opts("Find File"))
					vim.keymap.set("n", "h", api.node.navigate.parent, opts("Parent Directory"))
					vim.keymap.set("n", "i", api.fs.create, opts("Create File Or Directory"))
					vim.keymap.set("n", "l", api.node.navigate.sibling.next, opts("Next Sibling"))
					vim.keymap.set("n", "o", api.fs.create, opts("Create File Or Directory"))
					vim.keymap.set("n", "p", api.fs.paste, opts("Paste File"))
					vim.keymap.set("n", "s", api.tree.search_node, opts("Find File"))
					vim.keymap.set("n", "x", api.fs.remove, opts("Delete File"))
					vim.keymap.set("n", "y", api.fs.copy.node, opts("Yank File"))
				end

				tree.setup({
					on_attach = my_on_attach,
					view = { width = 35 },
					renderer = {
						add_trailing = true,
						root_folder_label = ":~",
						indent_width = 1,
						special_files = {},
						highlight_git = "name",
						highlight_diagnostics = "name",
						highlight_modified = "name",
						indent_markers = { enable = true },
						icons = {
							git_placement = "right_align",
							modified_placement = "signcolumn",
							glyphs = {
								git = {
									unstaged = "M",
									staged = "A",
									unmerged = "M",
									renamed = "R",
									untracked = "U",
									deleted = "D",
									ignored = "I",
								},
							},
						},
					},
					git = { show_on_open_dirs = false },
					diagnostics = {
						enable = true,
						show_on_open_dirs = false,
						icons = {
							hint = "h",
							info = "i",
							warning = "",
							error = "",
						},
					},
					modified = { enable = true, show_on_open_dirs = false },
					filters = { enable = false },
					actions = { use_system_clipboard = false },
					trash = { cmd = "" },
					ui = { confirm = { remove = false, default_yes = true } },
				})
				api.tree.toggle({ find_file = true, focus = false })
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

		-- TODO: continue this configuration

		-- treesitter
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			event = { "BufReadPre", "BufNewFile" },
			main = "nvim-treesitter.configs",
			opts = {
				auto_install = true,
				-- ensure_installed = language_tree_sitter,
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

		-- autocompletion
		{
			"hrsh7th/nvim-cmp",
			event = { "InsertEnter" },
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

		-- status bar
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			event = { "BufReadPre", "BufNewFile" },
			opts = {
				options = {
					icons_enabled = true,
					theme = "auto",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = {
						statusline = { "NvimTree" },
						winbar = {},
					},
					ignore_focus = {},
					always_divide_middle = true,
					always_show_tabline = true,
					globalstatus = false,
					refresh = {
						statusline = 100,
						tabline = 100,
						winbar = 100,
					},
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				winbar = {
					lualine_a = { "buffers" },
					lualine_b = {},
					lualine_c = {},
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
				},
				inactive_winbar = {},
				extensions = {},
			},
		},

		{
			"stevearc/oil.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			cmd = { "Oil" },
			opts = {
				buf_options = { buflisted = true },
				constrain_cursor = "name",
				watch_for_changes = true,
				view_options = { show_hidden = true },
			},
		},

		-- TODO
	},
})
