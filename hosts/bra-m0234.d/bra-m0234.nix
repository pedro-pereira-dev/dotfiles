{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager

    ../../flakes.d/modules/system.nix
  ];

  dots.system.hostName = "bra-m0234";
  dots.system.platform = "aarch64-darwin";

  system.primaryUser = "pereiped";
  system.stateVersion = 7;
  users.users.${config.system.primaryUser}.home = "/Users/${config.system.primaryUser}";

  environment.shells = with pkgs; [ bashInteractive ];
  launchd.user.envVariables.LC_COLLATE = "C";
  programs.bash.completion.enable = true;
  programs.bash.enable = true;
  system.activationScripts.postActivation.text = ''
    bash=${pkgs.bashInteractive}/bin/bash
    user=${config.system.primaryUser}
    if ! dscl . -read "/Users/$user" UserShell | grep -qxF "UserShell: $bash"; then sudo chsh -s "$bash" "$user"; fi
  '';

  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.onActivation.extraEnv.HOMEBREW_NO_ENV_HINTS = "1";
  homebrew.onActivation.upgrade = true;

  homebrew.taps = [
    {
      name = "mattness/alacritty";
      trusted = true;
    }
  ];
  homebrew.casks = [
    "alt-tab"
    "firefox"
    "font-code-new-roman-nerd-font"
    "google-chrome"
    "handy"
    "karabiner-elements"
    "mattness/alacritty/alacritty-signed"
    "microsoft-outlook"
    "microsoft-teams"
    "rectangle"
    "stay"
    "tastytrade"
    "tunnelblick"
  ];

  environment.systemPackages = with pkgs; [
    fastfetch
    fzf
    git
    lazygit
    lima
    neovim
    opencode
    qemu
    tmux
    zoxide
  ];

  home-manager.users.${config.system.primaryUser} = {
    home.stateVersion = "25.11";
    home.file.".gitconfig.default".text = ''
      [user]
        email = "11753516+pedro-pereira-dev@users.noreply.github.com"
        signingkey = "B1B18907C404F134"
    '';
    home.file.".gitconfig.mercedes".text = ''
      [user]
        email = "pedro.pereira@mercedes-benz.com"
        signingkey = "23440B98CDDDA9F3"
    '';
    home.file.".local/bin/nvim-reloadable" = {
      executable = true;
      text = ''
        #!/bin/bash
        while true; do
          $(which nvim) "$@"
          [ $? -ne 1 ] && break
        done
      '';
    };
    home.file.".local/bin/code" = {
      executable = true;
      text = ''
        #!/bin/bash

        function has_tmux_session() { tmux has-session -t="$1" >/dev/null 2>&1; }
        function is_tmux_running() { [[ -n $(pgrep tmux) ]] && return 0 || return 1; }
        function is_tmux_session() { [[ -n ''${TMUX} ]] && return 0 || return 1; }
        function find_target() {
          find ~/workspace -type d \
            -exec /bin/test -d '{}/.git' -a '{}' != '.' \; -print -prune \
            -o -print
        }

        TARGET=$(zoxide query "''${@:1}" 2>/dev/null)
        [[ -z ''${*:1} ]] && TARGET=$(find_target | fzf)
        [[ -n ''${*:1} && -z ''${TARGET} ]] && TARGET=$(find_target | fzf --query "''${*:1}")
        [[ -z ''${TARGET} ]] && exit 0

        REALPATH_TARGET=$(realpath "''${TARGET}")
        SESSION_NAME=$(basename "''${REALPATH_TARGET}")

        if is_tmux_session; then
          if ! has_tmux_session "''${SESSION_NAME}"; then
            # creates new detached session
            tmux new-session -d -s "''${SESSION_NAME}" -c "''${REALPATH_TARGET}"
          fi
          # switches to session
          tmux switch-client -t "''${SESSION_NAME}"
        else
          if has_tmux_session "''${SESSION_NAME}"; then
            # attaches to session and detaches all other clients from all sessions
            tmux attach -t "''${SESSION_NAME}" \; detach-client -a
          else
            # creates and attaches new session, and detaches all other clients from all sessions
            tmux new-session -s "''${SESSION_NAME}" -c "''${REALPATH_TARGET}" \; detach-client -a
          fi
        fi
      '';
    };
    programs.bash = {
      enable = true;
      initExtra = ''
        #!/usr/bin/env bash
        # Bash configuration (macOS / bra-m0234).
        # NOTE: the dotfiles repo no longer ships bash rc files; keep this in sync manually.

        # Prepend a directory to PATH if it exists and is not already present.
        _prepend_path() {
          if [[ -d $1 && ":$PATH:" != *":$1:"* ]]; then
            export PATH="$1:$PATH"
          fi
        }

        # Homebrew
        if [[ -x /opt/homebrew/bin/brew ]]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        _prepend_path "$HOME/.local/bin"
        _prepend_path "$HOME/.local/share/fnm"
        _prepend_path "$HOME/.luarocks/bin"
        _prepend_path "$HOME/.opencode/bin"

        if [[ $- == *i* ]]; then
          # fnm (interactive only)
          if command -v fnm >/dev/null 2>&1; then
            eval "$(fnm env --use-on-cd --shell bash)"
          fi
        fi

        unset -f _prepend_path
      '';
    };
    programs.git = {
      enable = true;
      settings = {
        commit.gpgsign = true;
        push = {
          autoSetupRemote = true;
          default = "current";
        };
        url."ssh://git@github.com/".pushInsteadOf = "https://github.com/";
        user.name = "Pedro Pereira";
      };
      includes = [
        { path = "~/.gitconfig.default"; }
        {
          condition = "gitdir:~/workspace/work/";
          path = "~/.gitconfig.mercedes";
        }
      ];
    };
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = { };
      extraConfig = ''
        Host github.com
          HostName github.com
          IdentityFile ~/.ssh/secrets/ssh-github-pedro-pereira-dev/private.key

        Host git.i.mercedes-benz.com
          HostName git.i.mercedes-benz.com
          IdentityFile ~/.ssh/secrets/ssh-mercedes-github-pesoare/private.key

        Include config.d/*
      '';
    };
    programs.tmux = {
      enable = true;
      extraConfig = ''
        set-hook -g session-created "send-keys 'command -v nvim-reloadable && tmux rename-window nvim && nvim-reloadable || true' ENTER"

        # tmux / neovim integration
        set -ag terminal-overrides ",xterm-256color:RGB" # for italics
        set -g default-terminal "tmux-256color" # for colors
        set -sg escape-time 0 # vim escape press delay
        # mouse support
        set -g mouse on
        set -g history-limit 50000
        # numeric windows
        set -g base-index 1
        setw -g pane-base-index 1

        # status bar layout
        set -g status-left ''\'''\'
        set -g status-position 'top'
        set -g status-right '#[align=right]#([[ -n $(tmux show-option -qv key-table) ]] && echo "#[fg=brightred]󰹋 ")#([[ -n $(tmux show-env | grep ^SSH_CONNECTION=) ]] && echo "#[fg=brightblack,nobold]$(whoami)@#h#[fg=white]  ")  #[fg=white,bold]#S'
        # status bar appearance
        set -g status-style 'bg=default fg=white,bold'
        set -g mode-style 'bg=default,fg=white,bold'
        set -g window-status-format '#[fg=brightblack,nobold]#I #W  '
        set -g window-status-current-format '#I #W  '

        # default keybindings - https://gist.github.com/mzmonsour/8791835
        bind-key -n m-D run-shell "tmux detach-client"
        bind-key -n m-R run-shell "tmux source-file ~/.config/tmux/tmux.conf"
        bind-key -n m-r run-shell "tmux neww code"
        # create windows - alt + pt
        bind-key -n m-p run-shell "tmux split-window -h"
        bind-key -n m-P run-shell "tmux split-window -v"
        bind-key -n m-t run-shell "tmux new-window"
        # select tabs - alt + #
        bind-key -n m-1 if-shell "tmux select-window -t :1" ''\'''\' "new-window -t :1"
        bind-key -n m-2 if-shell "tmux select-window -t :2" ''\'''\' "new-window -t :2"
        bind-key -n m-3 if-shell "tmux select-window -t :3" ''\'''\' "new-window -t :3"
        bind-key -n m-4 if-shell "tmux select-window -t :4" ''\'''\' "new-window -t :4"
        bind-key -n m-5 if-shell "tmux select-window -t :5" ''\'''\' "new-window -t :5"
        bind-key -n m-6 if-shell "tmux select-window -t :6" ''\'''\' "new-window -t :6"
        bind-key -n m-7 if-shell "tmux select-window -t :7" ''\'''\' "new-window -t :7"
        bind-key -n m-8 if-shell "tmux select-window -t :8" ''\'''\' "new-window -t :8"
        bind-key -n m-9 if-shell "tmux select-window -t :9" ''\'''\' "new-window -t :9"
        bind-key -n m-0 if-shell "tmux select-window -t :0" ''\'''\' "new-window -t :0"
        # rename windows - alt + shift + pts
        bind-key -n m-T run-shell "tmux command-prompt -I 'rename-window '"
        bind-key -n m-S run-shell "tmux command-prompt -I 'rename-session '"
        # resize panes - alt + shift + hjkl
        bind-key -n m-H run-shell "tmux resize-pane -L"
        bind-key -n m-J run-shell "tmux resize-pane -D"
        bind-key -n m-K run-shell "tmux resize-pane -U"
        bind-key -n m-L run-shell "tmux resize-pane -R"
        # disables bindings to use with nested sessions
        bind-key -T off m-Escape run-shell "tmux set -u prefix ; tmux set -u key-table ; tmux refresh-client -S"
        bind-key -T root m-Escape run-shell "tmux set prefix None ; tmux set key-table off ; tmux refresh-client -S"

        # integrates tmux and neovim navigation
        # https://github.com/christoomey/vim-tmux-navigator/
        vim_pattern='(\S+/)?g?\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?'
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep --extended-regexp --ignore-case --quiet '^[^TXZ ]+ +''${vim_pattern}'"
        # navigates panes - alt + hjkl
        bind-key -n 'm-h' if-shell "$is_vim" 'send-keys m-h' 'select-pane -L'
        bind-key -n 'm-j' if-shell "$is_vim" 'send-keys m-j' 'select-pane -D'
        bind-key -n 'm-k' if-shell "$is_vim" 'send-keys m-k' 'select-pane -U'
        bind-key -n 'm-l' if-shell "$is_vim" 'send-keys m-l' 'select-pane -R'
        # kills panes - alt + qQ
        bind-key -n 'm-Q' if-shell "$is_vim" 'send-keys m-Q' 'kill-session'
        bind-key -n 'm-q' if-shell "$is_vim" 'send-keys m-q' 'kill-pane'
      '';
    };
    programs.alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";
        window = {
          padding = {
            x = 8;
            y = 4;
          };
          dynamic_padding = true;
          option_as_alt = "OnlyLeft";
        };
        font = {
          size = 14;
          normal.family = "CodeNewRoman Nerd Font Mono";
        };
        colors = {
          primary = {
            foreground = "#d2d1e6";
            background = "#000000";
          };
          normal = {
            black = "#2e3440";
            red = "#ff3242";
            green = "#44bc44";
            yellow = "#ff9400";
            blue = "#0883ff";
            magenta = "#d930d9";
            cyan = "#00d8eb";
            white = "#d8dee9";
          };
          bright = {
            black = "#4c566a";
            red = "#ff6e6e";
            green = "#9ec875";
            yellow = "#ffaf00";
            blue = "#47bfe6";
            magenta = "#d294ff";
            cyan = "#8ae2f0";
            white = "#eceff4";
          };
        };
        selection.save_to_clipboard = true;
        cursor = {
          style.blinking = "Always";
          blink_interval = 250;
          blink_timeout = 0;
        };
        keyboard.bindings =
          let
            ctrl_shift = key: action: {
              inherit key action;
              mods = "Control|Shift";
            };
          in
          [
            (ctrl_shift "0" "ResetFontSize")
            (ctrl_shift "=" "ResetFontSize")
            (ctrl_shift "_" "DecreaseFontSize")
            (ctrl_shift "-" "DecreaseFontSize")
            (ctrl_shift "*" "IncreaseFontSize")
            (ctrl_shift "+" "IncreaseFontSize")
            (ctrl_shift "C" "Copy")
            (ctrl_shift "V" "Paste")
            (ctrl_shift "PageUp" "ScrollPageUp")
            (ctrl_shift "PageDown" "ScrollPageDown")
            {
              key = "Back";
              mods = "Control";
              chars = builtins.fromJSON ''"\u0017"'';
            }
            {
              key = "Delete";
              mods = "Control";
              chars = builtins.fromJSON ''"\u001bd"'';
            }
            {
              key = "Left";
              mods = "Control";
              chars = builtins.fromJSON ''"\u001bb"'';
            }
            {
              key = "Right";
              mods = "Control";
              chars = builtins.fromJSON ''"\u001bf"'';
            }
            {
              key = "F";
              mods = "Control|Shift";
              mode = "~Search";
              action = "SearchBackward";
            }
            {
              key = "F";
              mods = "Control|Shift";
              mode = "Search";
              action = "SearchFocusNext";
            }
            {
              key = "Escape";
              mode = "Search|~Vi";
              action = "ToggleViMode";
            }
            {
              key = "Escape";
              mode = "Search";
              action = "SearchConfirm";
            }
          ];
        mouse.bindings = [
          {
            mouse = "Right";
            action = "Paste";
          }
        ];
      };
    };
    xdg.configFile."nvim/init.lua".text = ''
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
      						{ key = "e", group = "fg", action = "Oil --preview", desc = " Explore" },
      						{ key = "s", group = "fg", action = "Lazy sync", desc = "󰒲 Sync" },
      						{ key = "m", group = "fg", action = "Mason", desc = " Mason" },
      						{ key = "q", group = "fg", action = "cq", desc = " Reload" },
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
    '';
  };
}
