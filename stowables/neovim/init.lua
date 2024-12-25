-- global vim options
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_node_provider = 0 -- FIXME: temporary to test performance on macos
vim.g.loaded_perl_provider = 0 -- FIXME: temporary to test performance on macos
vim.g.loaded_python_provider = 0 -- FIXME: temporary to test performance on macos
vim.g.loaded_ruby_provider = 0 -- FIXME: temporary to test performance on macos
vim.g.loaded_python3_provider = 0 -- FIXME: temporary to test performance on macos
-- mouse support
vim.opt.mouse = "a"
-- temporary files
vim.opt.swapfile = false
vim.opt.undofile = true
-- panes direction
vim.opt.splitbelow = true
vim.opt.splitright = true
-- visual appearance
vim.opt.colorcolumn = "80,100,120"
vim.opt.cursorline = true
vim.opt.numberwidth = 5
vim.opt.scrolloff = 15
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
-- line numbers
vim.opt.number = true
vim.opt.relativenumber = true
-- tabs as spaces
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
-- text formatting
vim.opt.linebreak = true
vim.opt.smartindent = true
-- smart search
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- netrw
vim.g.netrw_banner = 0 -- gets rid of the annoying banner for netrw
vim.g.netrw_browse_split = 4 -- open in prior window
vim.g.netrw_altv = 1 -- change from left splitting to right splitting
vim.g.netrw_liststyle = 3 -- tree style view in netrw
vim.opt.title = true

-- keymaps
local neovim_keymaps = function()
	-- centered default mappings
	vim.keymap.set("n", "<c-d>", "<c-d>zzzv", { desc = "Centered half page down" })
	vim.keymap.set("n", "<c-u>", "<c-u>zzzv", { desc = "Centered half page up" })
	vim.keymap.set("n", "N", "Nzzzv", { desc = "Centered previous occurrence" })
	vim.keymap.set("n", "n", "nzzzv", { desc = "Centered next occurrence" })
	vim.keymap.set("n", "{", "{zzzv", { desc = "Centered previous paragraph" })
	vim.keymap.set("n", "}", "}zzzv", { desc = "Centered next paragraph" })
	-- clipboard
	vim.keymap.set({ "n", "v" }, "<leader>cp", [["+p]], { desc = "Pastes from clipboard" })
	vim.keymap.set({ "n", "v" }, "<leader>cy", [["+y]], { desc = "Copies selection to clipboard" })
	-- navigation
	vim.keymap.set("n", "<leader>q", ":bd!<cr>", { silent = true, desc = "Quits buffer" })
	vim.keymap.set("n", "<tab>", ":b#<cr>zzzv", { desc = "Go to previous buffer" })
	vim.keymap.set("n", "<c-h>", "<c-w>h", { desc = "Navigate to left window" })
	vim.keymap.set("n", "<c-j>", "<c-w>j", { desc = "Navigate to down window" })
	vim.keymap.set("n", "<c-k>", "<c-w>k", { desc = "Navigate to up window" })
	vim.keymap.set("n", "<c-l>", "<c-w>l", { desc = "Navigate to right window" })
	-- operations
	vim.keymap.set("n", "<esc>", ":nohlsearch<cr>", { silent = true, desc = "Clears search highlights" })
	vim.keymap.set("n", "<leader>cq", ":q!<cr>", { silent = true, desc = "Quits neovim" })
	vim.keymap.set("n", "<leader>cr", ":cq<cr>", { desc = "Reloads neovim" })
	vim.keymap.set("n", "<leader>cc", ":e ~/.config/nvim/init.lua<cr>", { desc = "Opens configurations" })
	vim.keymap.set("n", "<leader>r", ":e!<cr>zzzv", { desc = "Reloads buffer" })
	vim.keymap.set("n", "<leader>w", ":w<cr>", { desc = "Writes buffer" })
	vim.keymap.set("v", "<leader>s", ":sort<cr>", { silent = true, desc = "Sorts selected lines" })
	vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { silent = true, desc = "Moves selected lines down" })
	vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { silent = true, desc = "Moves selected lines up" })
	vim.keymap.set("n", "<leader>c", ":normal gcc<cr>", { silent = true, desc = "Toggle line comment" })
	-- FIXME: visual comments --vim.keymap.set("v", "<leader>c", "gc", { silent = true, desc = "Toggle line comment" })
end
local telescope_keymaps = function(pickers)
	-- files
	vim.keymap.set("n", "<leader>o", pickers.find_files, { desc = "Open project file" })
	-- buffers
	vim.keymap.set("n", "<leader><tab>", pickers.buffers, { desc = "List buffers" })
	-- command palette
	vim.keymap.set("n", "<leader><cr>", pickers.menu, { desc = "List custom commands" })

	-- FIXME: implement project switching
	-- vim.keymap.set("n", "<leader>p<tab>", function()
	-- 	session_picker(themes.get_ivy())
	-- end, { desc = "Misc: [p]rojects [tab]le" })
	-- vim.keymap.set("n", "<leader>pl", function()
	-- 	session_manager(themes.get_ivy())
	-- end, { desc = "Misc: [p]roject [l]oad" })
	-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Misc: [p]roject [v]iew" })
	-- vim.keymap.set("n", "<leader>sw", builtin.live_grep, { desc = "Misc: [s]earch [w]ord" })
	-- vim.keymap.set("n", "<leader>ff", function()
	-- 	builtin.find_files({ cwd = "~" })
	-- end, { desc = "Misc: [f]ind [f]iles" })
end

-- FIXME: check usability of these
-- vim.keymap.set({ "n", "v" }, "<leader>d", '"_d') -- deletes to void
-- vim.keymap.set("v", "<leader>gr", '"hy:%s/<C-r>h//g<left><left>') -- Replace all instances of highlighted words
-- vim.keymap.set("n", "<leader>e", ":25Lex!<cr>") -- space+e toggles netrw tree view
-- vim.keymap.set("n", "J", "mzJ`z") -- append to end of line without moving cursor
-- vim.keymap.set("x", "<leader>p", [["_dP]]) -- repaces with past and sends to void
-- vim.keymap.set({"n", "v"}, "<leader>d", [["_d]]) -- deletes to void
-- vim.keymap.set("i", "<C-c>", "<Esc>")
-- vim.keymap.set("n", "Q", "<nop>")
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
-- vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
-- vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- map("n", "<C-Left>", ":vertical resize +3<CR>")		-- Control+Left resizes vertical split +
-- map("n", "<C-Right>", ":vertical resize -3<CR>")	-- Control+Right resizes vertical split -
-- map("i", "kj", "<Esc>")					-- kj simulates ESC
-- map("i", "jk", "<Esc>")					-- jk simulates ESC

-- highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Function to get the full path and replace the home directory with ~
local function get_winbar_path()
	local full_path = vim.fn.expand("%:p")
	return full_path:gsub(vim.fn.expand("$HOME"), "~")
end
-- Function to get the number of open buffers using the :ls command
local function get_buffer_count()
	local buffers = vim.fn.execute("ls")
	local count = 0
	-- Match only lines that represent buffers, typically starting with a number followed by a space
	for line in string.gmatch(buffers, "[^\r\n]+") do
		if string.match(line, "^%s*%d+") then
			count = count + 1
		end
	end
	return count
end
-- Autocmd to update the winbar on BufEnter and WinEnter events
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
	callback = function()
		local home_replaced = get_winbar_path()
		local buffer_count = get_buffer_count()
		vim.opt.winbar = "(" .. buffer_count .. ") " .. home_replaced .. " %m%*%="
	end,
})

-- vim.api.nvim_create_autocmd({ "VimEnter" }, {
-- 	callback = function()
-- 		require("nvim-tree.api").tree.open()
-- 	end,
-- })

-- neovim custom keymaps
neovim_keymaps()

-- bootstraps lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- installs plugins
require("lazy").setup({
	-- adds colorscheme
	{
		"blazkowolf/gruber-darker.nvim",
		init = function()
			vim.cmd.colorscheme("gruber-darker")
		end,
	},

	-- {
	-- 	"nvim-lualine/lualine.nvim",
	-- 	dependencies = { "nvim-tree/nvim-web-devicons" },
	-- },

	-- {
	-- 	"nvim-tree/nvim-tree.lua",
	-- 	version = "*",
	-- 	lazy = false,
	-- 	dependencies = {
	-- 		"nvim-tree/nvim-web-devicons",
	-- 	},
	-- 	config = function()
	-- 		require("nvim-tree").setup({
	-- 			filters = { dotfiles = false },
	-- 			disable_netrw = true,
	-- 			hijack_cursor = true,
	-- 			sync_root_with_cwd = true,
	-- 			update_focused_file = {
	-- 				enable = true,
	-- 				update_root = false,
	-- 			},
	-- 			view = {
	-- 				width = 30,
	-- 				preserve_window_proportions = true,
	-- 			},
	-- 			renderer = {
	-- 				root_folder_label = false,
	-- 				highlight_git = true,
	-- 				indent_markers = { enable = true },
	-- 				icons = {
	-- 					glyphs = {
	-- 						default = "󰈚",
	-- 						folder = {
	-- 							default = "",
	-- 							empty = "",
	-- 							empty_open = "",
	-- 							open = "",
	-- 							symlink = "",
	-- 						},
	-- 						git = { unmerged = "" },
	-- 					},
	-- 				},
	-- 			},
	-- 		})
	-- 	end,
	-- },

	-- {
	-- 	"nvim-neo-tree/neo-tree.nvim",
	-- 	branch = "v3.x",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
	-- 		"MunifTanjim/nui.nvim",
	-- 		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	-- 	},
	-- },

	{
		"ggandor/leap.nvim",
		dependencies = { "tpope/vim-repeat" },
		config = function()
			require("leap").opts.safe_labels = {
				"a",
				"s",
				"d",
				"f",
				"h",
				"j",
				"k",
				"l",
				"w",
				"e",
				"r",
				"u",
				"i",
				"o",
				"p",
				"q",
				"g",
				"t",
				"y",
				"c",
				"v",
				"m",
				"n",
				"b",
				"x",
				"z",
			}
			vim.keymap.set({ "n", "x", "o" }, "<leader><leader>", "<Plug>(leap)")
		end,
	},

	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()

			vim.keymap.set("n", "<leader>a", function()
				harpoon:list():add()
			end)
			vim.keymap.set("n", "<leader>h", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end)

			vim.keymap.set("n", "<leader>1", function()
				harpoon:list():select(1)
			end)
			vim.keymap.set("n", "<leader>2", function()
				harpoon:list():select(2)
			end)
			vim.keymap.set("n", "<leader>3", function()
				harpoon:list():select(3)
			end)
			vim.keymap.set("n", "<leader>4", function()
				harpoon:list():select(4)
			end)
		end,
	},

	-- fuzzy finder for files, lsp, git, commands, ...
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons" },
		},
		config = function()
			local telescope = require("telescope")

			local actions = require("telescope.actions")
			local builtin = require("telescope.builtin")
			local finders = require("telescope.finders")
			local pickers = require("telescope.pickers")
			local themes = require("telescope.themes")

			local action_state = require("telescope.actions.state")
			local conf = require("telescope.config").values

			local log = require("plenary.log"):new()
			log.level = "debug"

			telescope.setup({
				defaults = {
					mappings = {
						i = {
							["<esc>"] = actions.close,
							["<s-tab>"] = actions.move_selection_better,
							["<tab>"] = actions.move_selection_worse,
						},
						n = {
							["<esc>"] = actions.close,
							["<s-tab>"] = actions.move_selection_better,
							["<tab>"] = actions.move_selection_worse,
							["h"] = actions.close,
							["l"] = actions.select_default,
						},
					},
					prompt_prefix = "  ",
					selection_caret = " ",
				},
				pickers = {
					buffers = {
						initial_mode = "normal",
						mappings = {
							n = {
								["d"] = actions.delete_buffer,
							},
						},
						prompt_prefix = "   ",
						sort_lastused = true,
						theme = "ivy",
					},
					builtin = {
						initial_mode = "normal",
						prompt_prefix = "   ",
						theme = "ivy",
					},
					current_buffer_fuzzy_find = {
						theme = "ivy",
					},
					diagnostics = {
						initial_mode = "normal",
						prompt_prefix = "   ",
						theme = "ivy",
					},
					find_files = {
						find_command = { "rg", "--files", "--hidden", "--glob", "!{.git}" },
						prompt_prefix = "    ",
						theme = "ivy",
					},
					git_files = {
						theme = "ivy",
					},
					grep_string = {
						prompt_prefix = "    ",
						theme = "ivy",
					},
					keymaps = {
						initial_mode = "normal",
						prompt_prefix = "   ",
						theme = "ivy",
					},
					live_grep = {
						additional_args = function()
							return { "--hidden" }
						end,
						prompt_prefix = "    ",
						theme = "ivy",
					},
					oldfiles = {
						initial_mode = "normal",
						prompt_prefix = "     ",
						theme = "ivy",
					},
				},
				extensions = { ["ui-select"] = { themes.get_dropdown() }, fzf = {} },
			})
			pcall(telescope.load_extension, "fzf")
			pcall(telescope.load_extension, "ui-select")

			-- command palette custom picker
			local cmd_palette = function(opts)
				opts = opts or {}
				pickers
					.new(opts, {
						attach_mappings = function(prompt_bufnr)
							actions.select_default:replace(function()
								actions.close(prompt_bufnr)
								local cmd_selection = action_state.get_selected_entry().value[2]
								vim.cmd(cmd_selection)
							end)
							return true
						end,
						finder = finders.new_table({
							entry_maker = function(entry)
								return {
									display = entry[1],
									ordinal = entry[1],
									value = entry,
								}
							end,
							results = {
								{ "Lazy: Show Menu", "Lazy" },
								{ "Lazy: Upgrade Plugins", "Lazy sync" },
								{ "Neovim: Reload Window", "cq" },
								{ "Telescope: Find Word", "Telescope grep_string" },
								{ "Telescope: Find", "Telescope live_grep" },
								{ "Telescope: Open Any Files", "Telescope find_files" },
								{ "Telescope: Open Recent Files", "Telescope oldfiles" },
								{ "Telescope: Show Diagnostics", "Telescope diagnostics" },
								{ "Telescope: Show Keymaps", "Telescope keymaps" },
								{ "Telescope: Show Open Files", "Telescope buffers" },
								{ "Telescope: Show Selectors", "Telescope builtin" },
							},
						}),
						prompt_title = "Command Palette",
						sorter = conf.generic_sorter(opts),
					})
					:find()
			end

			-- session manager custom picker
			local session_manager = function(opts)
				opts = opts or {}
				pickers
					.new(opts, {
						attach_mappings = function(prompt_bufnr)
							actions.select_default:replace(function()
								local selection = action_state.get_selected_entry().value
								actions.close(prompt_bufnr)
								vim.system({ "tmux-sessionixidizer", selection })
							end)
							return true
						end,
						finder = finders.new_async_job({
							command_generator = function()
								return {
									"find",
									vim.env.HOME .. "/workspace/",
									"-name",
									".git",
									"-type",
									"d",
									"-exec",
									"dirname",
									"{}",
									";",
								}
							end,
						}),
						prompt_title = "Load Project",
						sorter = conf.generic_sorter(opts),
					})
					:find()
			end

			-- TODO: finishing stuff here
			local session_picker = function(opts)
				opts = opts or {}
				pickers
					.new(opts, {
						initial_mode = "normal",
						prompt_prefix = "     ",
						attach_mappings = function(prompt_bufnr, map)
							map("n", "d", function()
								log.debug("pressed D")
								local selection = action_state.get_selected_entry().value
								local project = selection:match("([^:]+)")
								actions.move_selection_next(prompt_bufnr)
								vim.system({ "tmux", "kill-session", "-t", project })
								local current_picker = action_state.get_current_picker(prompt_bufnr)
								current_picker:refresh()
							end)

							actions.select_default:replace(function()
								local selection = action_state.get_selected_entry().value
								local project = selection:match("([^:]+)")
								actions.close(prompt_bufnr)
								vim.system({ "tmux-sessionixidizer", project })
							end)
							return true
						end,
						finder = finders.new_async_job({
							command_generator = function()
								return { "tmux", "ls" }
							end,
						}),
						prompt_title = "Load Project",
						sorter = conf.generic_sorter(opts),
					})
					:find()
			end

			local cmd_palette_teste = function()
				cmd_palette(themes.get_ivy())
			end

			telescope_keymaps(vim.tbl_extend("force", { menu = cmd_palette_teste }, builtin))
		end,
	},

	-- {
	-- 	"folke/flash.nvim",
	-- 	event = "VeryLazy",
	-- 	keys = {
	-- 		{
	-- 			"<leader>f",
	-- 			mode = { "n", "x", "o" },
	-- 			function()
	-- 				require("flash").jump()
	-- 			end,
	-- 			desc = "Misc: [f]lash to word",
	-- 		},
	-- 	},
	-- 	opts = {
	-- 		-- labels priority
	-- 		labels = "asdfghjklqwertyuiopzxcvbnm",
	-- 		jump = {
	-- 			-- automatically jump when there is only one match
	-- 			autojump = true,
	-- 		},
	-- 		label = {
	-- 			-- allow uppercase labels
	-- 			uppercase = false,
	-- 			-- TODO
	-- 			-- show the label after the match
	-- 			after = true, ---@type boolean|number[]
	-- 			-- show the label before the match
	-- 			before = false, ---@type boolean|number[]
	-- 			-- position of the label extmark
	-- 			style = "overlay", ---@type "eol" | "overlay" | "right_align" | "inline"
	-- 			-- flash tries to re-use labels that were already assigned to a position,
	-- 			-- when typing more characters. By default only lower-case labels are re-used.
	-- 			reuse = "lowercase", ---@type "lowercase" | "all" | "none"
	-- 			-- for the current window, label targets closer to the cursor first
	-- 			distance = true,
	-- 			-- minimum pattern length to show labels
	-- 			-- Ignored for custom labelers.
	-- 			min_pattern_length = 0,
	-- 			-- Enable this to use rainbow colors to highlight labels
	-- 			-- Can be useful for visualizing Treesitter ranges.
	-- 			rainbow = {
	-- 				enabled = false,
	-- 				-- number between 1 and 9
	-- 				shade = 5,
	-- 			},
	-- 			-- With `format`, you can change how the label is rendered.
	-- 			-- Should return a list of `[text, highlight]` tuples.
	-- 			---@class Flash.Format
	-- 			---@field state Flash.State
	-- 			---@field match Flash.Match
	-- 			---@field hl_group string
	-- 			---@field after boolean
	-- 			---@type fun(opts:Flash.Format): string[][]
	-- 			format = function(opts)
	-- 				return { { opts.match.label, opts.hl_group } }
	-- 			end,
	-- 		},
	-- 		highlight = {
	-- 			-- show a backdrop with hl FlashBackdrop
	-- 			backdrop = true,
	-- 			-- Highlight the search matches
	-- 			matches = true,
	-- 			-- extmark priority
	-- 			priority = 5000,
	-- 			groups = {
	-- 				match = "FlashMatch",
	-- 				current = "FlashCurrent",
	-- 				backdrop = "FlashBackdrop",
	-- 				label = "FlashLabel",
	-- 			},
	-- 		},
	-- 		-- action to perform when picking a label.
	-- 		-- defaults to the jumping logic depending on the mode.
	-- 		---@type fun(match:Flash.Match, state:Flash.State)|nil
	-- 		action = nil,
	-- 		-- initial pattern to use when opening flash
	-- 		pattern = "",
	-- 		-- When `true`, flash will try to continue the last search
	-- 		continue = false,
	-- 		-- Set config to a function to dynamically change the config
	-- 		config = nil, ---@type fun(opts:Flash.Config)|nil
	-- 		-- You can override the default options for a specific mode.
	-- 		-- Use it with `require("flash").jump({mode = "forward"})`
	-- 		---@type table<string, Flash.Config>
	-- 		modes = {
	-- 			-- options used when flash is activated through
	-- 			-- a regular search with `/` or `?`
	-- 			search = {
	-- 				-- when `true`, flash will be activated during regular search by default.
	-- 				-- You can always toggle when searching with `require("flash").toggle()`
	-- 				enabled = false,
	-- 				highlight = { backdrop = false },
	-- 				jump = { history = true, register = true, nohlsearch = true },
	-- 				search = {
	-- 					-- `forward` will be automatically set to the search direction
	-- 					-- `mode` is always set to `search`
	-- 					-- `incremental` is set to `true` when `incsearch` is enabled
	-- 				},
	-- 			},
	-- 			-- options used when flash is activated through
	-- 			-- `f`, `F`, `t`, `T`, `;` and `,` motions
	-- 			char = {
	-- 				enabled = true,
	-- 				-- dynamic configuration for ftFT motions
	-- 				config = function(opts)
	-- 					-- autohide flash when in operator-pending mode
	-- 					opts.autohide = opts.autohide or (vim.fn.mode(true):find("no") and vim.v.operator == "y")
	--
	-- 					-- disable jump labels when not enabled, when using a count,
	-- 					-- or when recording/executing registers
	-- 					opts.jump_labels = opts.jump_labels
	-- 						and vim.v.count == 0
	-- 						and vim.fn.reg_executing() == ""
	-- 						and vim.fn.reg_recording() == ""
	--
	-- 					-- Show jump labels only in operator-pending mode
	-- 					-- opts.jump_labels = vim.v.count == 0 and vim.fn.mode(true):find("o")
	-- 				end,
	-- 				-- hide after jump when not using jump labels
	-- 				autohide = false,
	-- 				-- show jump labels
	-- 				jump_labels = false,
	-- 				-- set to `false` to use the current line only
	-- 				multi_line = true,
	-- 				-- When using jump labels, don't use these keys
	-- 				-- This allows using those keys directly after the motion
	-- 				label = { exclude = "hjkliardc" },
	-- 				-- by default all keymaps are enabled, but you can disable some of them,
	-- 				-- by removing them from the list.
	-- 				-- If you rather use another key, you can map them
	-- 				-- to something else, e.g., { [";"] = "L", [","] = H }
	-- 				keys = { "f", "F", "t", "T", ";", "," },
	-- 				---@alias Flash.CharActions table<string, "next" | "prev" | "right" | "left">
	-- 				-- The direction for `prev` and `next` is determined by the motion.
	-- 				-- `left` and `right` are always left and right.
	-- 				char_actions = function(motion)
	-- 					return {
	-- 						[";"] = "next", -- set to `right` to always go right
	-- 						[","] = "prev", -- set to `left` to always go left
	-- 						-- clever-f style
	-- 						[motion:lower()] = "next",
	-- 						[motion:upper()] = "prev",
	-- 						-- jump2d style: same case goes next, opposite case goes prev
	-- 						-- [motion] = "next",
	-- 						-- [motion:match("%l") and motion:upper() or motion:lower()] = "prev",
	-- 					}
	-- 				end,
	-- 				search = { wrap = false },
	-- 				highlight = { backdrop = true },
	-- 				jump = {
	-- 					register = false,
	-- 					-- when using jump labels, set to 'true' to automatically jump
	-- 					-- or execute a motion when there is only one match
	-- 					autojump = false,
	-- 				},
	-- 			},
	-- 			-- options used for treesitter selections
	-- 			-- `require("flash").treesitter()`
	-- 			treesitter = {
	-- 				labels = "abcdefghijklmnopqrstuvwxyz",
	-- 				jump = { pos = "range", autojump = true },
	-- 				search = { incremental = false },
	-- 				label = { before = true, after = true, style = "inline" },
	-- 				highlight = {
	-- 					backdrop = false,
	-- 					matches = false,
	-- 				},
	-- 			},
	-- 			treesitter_search = {
	-- 				jump = { pos = "range" },
	-- 				search = { multi_window = true, wrap = true, incremental = false },
	-- 				remote_op = { restore = true },
	-- 				label = { before = true, after = true, style = "inline" },
	-- 			},
	-- 			-- options used for remote flash
	-- 			remote = {
	-- 				remote_op = { restore = true, motion = true },
	-- 			},
	-- 		},
	-- 		-- options for the floating window that shows the prompt,
	-- 		-- for regular jumps
	-- 		-- `require("flash").prompt()` is always available to get the prompt text
	-- 		prompt = {
	-- 			enabled = true,
	-- 			prefix = { { "⚡", "FlashPromptIcon" } },
	-- 			win_config = {
	-- 				relative = "editor",
	-- 				width = 1, -- when <=1 it's a percentage of the editor width
	-- 				height = 1,
	-- 				row = -1, -- when negative it's an offset from the bottom
	-- 				col = 0, -- when negative it's an offset from the right
	-- 				zindex = 1000,
	-- 			},
	-- 		},
	-- 		-- options for remote operator pending mode
	-- 		remote_op = {
	-- 			-- restore window views and cursor position
	-- 			-- after doing a remote operation
	-- 			restore = false,
	-- 			-- For `jump.pos = "range"`, this setting is ignored.
	-- 			-- `true`: always enter a new motion when doing a remote operation
	-- 			-- `false`: use the window's cursor position and jump target
	-- 			-- `nil`: act as `true` for remote windows, `false` for the current window
	-- 			motion = false,
	-- 		},
	-- 	},
	-- },

	-- --	file manager
	-- {
	-- 	"stevearc/oil.nvim",
	-- 	opts = {},
	-- 	dependencies = { "nvim-tree/nvim-web-devicons" },
	-- 	config = function()
	-- 		local oil = require("oil")
	-- 		local oil_actions = require("oil.actions")
	--
	-- 		oil.setup({
	-- 			columns = {
	-- 				"icon",
	-- 				"permissions",
	-- 			},
	-- 			skip_confirm_for_simple_edits = true,
	-- 			prompt_save_on_select_new_entry = false,
	-- 			constrain_cursor = "name",
	-- 			keymaps = {
	-- 				["<bs>"] = "actions.parent",
	-- 				["<c-e>"] = "actions.open_cwd",
	-- 				["<c-r>"] = "actions.refresh",
	-- 				["<cr>"] = "actions.select",
	-- 				["gh"] = "<cmd>edit $HOME<cr>",
	-- 				["gr"] = "<cmd>edit /<cr>",
	-- 				["<esc>"] = function()
	-- 					oil_actions.close.callback()
	-- 				end,
	-- 			},
	-- 			use_default_keymaps = false,
	-- 			view_options = {
	-- 				show_hidden = true,
	-- 			},
	-- 		})
	--
	-- 		vim.keymap.set("n", "<leader>e", oil_actions.parent.callback)
	-- 	end,
	-- },

	-- adds small independent plugins
	{
		"echasnovski/mini.nvim",
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup({ n_lines = 500 })

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require("mini.surround").setup()

			-- Simple and easy statusline.
			--  You could remove this setup call if you don't like it,
			--  and try some other statusline plugin
			local statusline = require("mini.statusline")
			-- set use_icons to true if you have a Nerd Font
			statusline.setup({ use_icons = true })

			-- You can configure sections in the statusline by overriding their
			-- default behavior. For example, here we set the section for
			-- cursor location to LINE:COLUMN
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end

			-- ... and there is more!
			--  Check out: https://github.com/echasnovski/mini.nvim
		end,
	},

	-- {
	-- 	"akinsho/bufferline.nvim",
	-- 	dependencies = "nvim-tree/nvim-web-devicons",
	-- 	config = function()
	-- 		local bufferline = require("bufferline")
	-- 		bufferline.setup({
	-- 			options = {
	-- 				right_mouse_command = "buffer %d", -- can be a string | function | false, see "Mouse actions"
	-- 				middle_mouse_command = "bdelete! %d", -- can be a string | function, | false see "Mouse actions"
	-- 				indicator = { style = "underline" },
	-- 				diagnostics = "nvim_lsp",
	-- 				diagnostics_update_on_event = true, -- use nvim's diagnostic handler
	-- 				diagnostics_indicator = function(count, level)
	-- 					local icon = level:match("error") and " " or " "
	-- 					return " " .. icon .. count
	-- 				end,
	-- 			},
	-- 		})
	-- 	end,
	-- },

	{ -- Useful plugin to show you pending keybinds.
		"folke/which-key.nvim",
		event = "VimEnter", -- Sets the loading event to 'VimEnter'
		opts = {
			icons = {
				-- set icon mappings to true if you have a Nerd Font
				mappings = true,
				-- If you are using a Nerd Font: set icons.keys to an empty table which will use the
				-- default which-key.nvim defined Nerd Font icons, otherwise define a string table
				keys = true and {} or {
					Up = "<Up> ",
					Down = "<Down> ",
					Left = "<Left> ",
					Right = "<Right> ",
					C = "<C-…> ",
					M = "<M-…> ",
					D = "<D-…> ",
					S = "<S-…> ",
					CR = "<CR> ",
					Esc = "<Esc> ",
					ScrollWheelDown = "<ScrollWheelDown> ",
					ScrollWheelUp = "<ScrollWheelUp> ",
					NL = "<NL> ",
					BS = "<BS> ",
					Space = "<Space> ",
					Tab = "<Tab> ",
					F1 = "<F1>",
					F2 = "<F2>",
					F3 = "<F3>",
					F4 = "<F4>",
					F5 = "<F5>",
					F6 = "<F6>",
					F7 = "<F7>",
					F8 = "<F8>",
					F9 = "<F9>",
					F10 = "<F10>",
					F11 = "<F11>",
					F12 = "<F12>",
				},
			},

			-- Document existing key chains
			spec = {
				{ "<leader>C", group = "[C]ode", mode = { "n", "x" } },
				{ "<leader>d", group = "[D]ocument" },
				{ "<leader><leader>r", group = "[R]ename" },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			},
		},
	},

	-- LSP Plugins
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			{ "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ "j-hui/fidget.nvim", opts = {} },

			-- Allows extra capabilities provided by nvim-cmp
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- Brief aside: **What is LSP?**
			--
			-- LSP is an initialism you've probably heard, but might not understand what it is.
			--
			-- LSP stands for Language Server Protocol. It's a protocol that helps editors
			-- and language tooling communicate in a standardized fashion.
			--
			-- In general, you have a "server" which is some tool built to understand a particular
			-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
			-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
			-- processes that communicate with some "client" - in this case, Neovim!
			--
			-- LSP provides Neovim with features like:
			--  - Go to definition
			--  - Find references
			--  - Autocompletion
			--  - Symbol Search
			--  - and more!
			--
			-- Thus, Language Servers are external tools that must be installed separately from
			-- Neovim. This is where `mason` and related plugins come into play.
			--
			-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
			-- and elegantly composed help section, `:help lsp-vs-treesitter`

			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- NOTE: Remember that Lua is a real programming language, and as such it is possible
					-- to define small helper and utility functions so you don't have to repeat yourself.
					--
					-- In this case, we create a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

					-- Find references for the word under your cursor.
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					map(
						"<leader>fs",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("<leader><leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>Ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({
									group = "kickstart-lsp-highlight",
									buffer = event2.buf,
								})
							end,
						})
					end

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					--
					-- This may be unwanted, since they displace some of your code
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- Change diagnostic symbols in the sign column (gutter)
			-- if vim.g.have_nerd_font then
			--   local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
			--   local diagnostic_signs = {}
			--   for type, icon in pairs(signs) do
			--     diagnostic_signs[vim.diagnostic.severity[type]] = icon
			--   end
			--   vim.diagnostic.config { signs = { text = diagnostic_signs } }
			-- end

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
			local servers = {
				bashls = {},
				-- clangd = {},
				-- gopls = {},
				-- pyright = {},
				-- rust_analyzer = {},
				-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
				--
				-- Some languages (like typescript) have entire language plugins that can be useful:
				--    https://github.com/pmizio/typescript-tools.nvim
				--
				-- But for many setups, the LSP (`ts_ls`) will work just fine
				-- ts_ls = {},
				--

				lua_ls = {
					-- cmd = {...},
					-- filetypes = { ...},
					-- capabilities = {},
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
							-- diagnostics = { disable = { 'missing-fields' } },
						},
					},
				},
			}

			-- Ensure the servers and tools above are installed
			--  To check the current status of installed tools and/or manually install
			--  other tools, you can run
			--    :Mason
			--
			--  You can press `g?` for help in this menu.
			require("mason").setup()

			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for ts_ls)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local disable_filetypes = { c = true, cpp = true }
				local lsp_format_opt
				if disable_filetypes[vim.bo[bufnr].filetype] then
					lsp_format_opt = "never"
				else
					lsp_format_opt = "fallback"
				end
				return {
					timeout_ms = 500,
					lsp_format = lsp_format_opt,
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform can also run multiple formatters sequentially
				-- python = { "isort", "black" },
				--
				-- You can use 'stop_after_first' to run the first available formatter from the list
				-- javascript = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},

	{ -- Autocompletion
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    See the README about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					-- {
					--   'rafamadriz/friendly-snippets',
					--   config = function()
					--     require('luasnip.loaders.from_vscode').lazy_load()
					--   end,
					-- },
				},
			},
			"saadparwaiz1/cmp_luasnip",

			-- Adds other completion capabilities.
			--  nvim-cmp does not ship with all sources by default. They are split
			--  into multiple repos for maintenance purposes.
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},
		config = function()
			-- See `:help cmp`
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },

				-- For an understanding of why these mappings were
				-- chosen, you will need to read `:help ins-completion`
				--
				-- No, but seriously. Please read `:help ins-completion`, it is really good!
				mapping = cmp.mapping.preset.insert({
					-- Select the [n]ext item
					["<C-n>"] = cmp.mapping.select_next_item(),
					-- Select the [p]revious item
					["<C-p>"] = cmp.mapping.select_prev_item(),

					-- Scroll the documentation window [b]ack / [f]orward
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					-- Accept ([y]es) the completion.
					--  This will auto-import if your LSP supports it.
					--  This will expand snippets if the LSP sent a snippet.
					["<C-y>"] = cmp.mapping.confirm({ select = true }),

					-- If you prefer more traditional completion keymaps,
					-- you can uncomment the following lines
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),

					-- Manually trigger a completion from nvim-cmp.
					--  Generally you don't need this, because nvim-cmp will display
					--  completions whenever it has completion options available.
					["<C-Space>"] = cmp.mapping.complete({}),

					-- Think of <c-l> as moving to the right of your snippet expansion.
					--  So if you have a snippet that's like:
					--  function $name($args)
					--    $body
					--  end
					--
					-- <c-l> will move you to the right of each of the expansion locations.
					-- <c-h> is similar, except moving you backwards.
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),

					-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
					--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
				}),
				sources = {
					{
						name = "lazydev",
						-- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
						group_index = 0,
					},
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				},
			})
		end,
	},

	-- Highlight todo, notes, etc in comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs", -- Sets main module to use for opts
		-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
				"xml",
			},
			-- Autoinstall languages that are not installed
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = { "ruby" } },
		},
	},
}, {
	rocks = {
		enabled = false,
	},
})
