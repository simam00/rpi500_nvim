-- Set space as leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Interface
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
-- Show diagnostic popup on cursor
vim.keymap.set('n', '<space>d', vim.diagnostic.open_float)

-- Jump to previous/next error
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

vim.keymap.set('n', '<Leader>h', '<C-w>h')
vim.keymap.set('n', '<Leader>j', '<C-w>j')
vim.keymap.set('n', '<Leader>k', '<C-w>k')
vim.keymap.set('n', '<Leader>l', '<C-w>l')

-- Plugin Manager lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Plugins (Mason Setup)
require("lazy").setup({
  
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {"pylsp", "lua_ls"},
    }
  },

  {
    "neovim/nvim-lspconfig",
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- mocha, latte, frappe, macchiato
        transparent_background = false,
        term_colours = true,
        integrations = {
          mason = true,
          neotree = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
          },
	},
      })
  vim.cmd.colorscheme "catppuccin"
end,
  },
  
  -- TELESCOPE (Fuzzy Finder)
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      -- Keymaps
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {}) -- Find File
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})  -- Live Grep (Text)
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})    -- Find Buffer
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})  -- Help
    end
  },
  
  -- NEO-TREE (Sidebar File Explorer)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- Requires Nerd Font
      "MunifTanjim/nui.nvim",
    },
    config = function()
      -- Keymap to toggle the sidebar
      vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', {})
    end
  },
  
  -- TERMINAL TOGGLE
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]], -- Ctrl + backslash to toggle
        direction = 'float', -- 'vertical' | 'horizontal' | 'tab' | 'float'
        float_opts = {
          border = 'curved', 
        }
      })
    end
  },
 
  -- DEBUGGER (DAP)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- 1. Setup UI (The windows)
      dapui.setup()

      -- 2. Setup Python Adapter
      -- Note: We assume Mason installed 'debugpy'. 
      -- The path usually looks like this on Linux/Pi:
      local debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(debugpy_path)

      -- 3. Auto-open UI when debugging starts
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

      -- 4. Keybindings (Standard IDE keys)
      vim.keymap.set('n', '<F5>', function() dap.continue() end)          -- Start / Continue
      vim.keymap.set('n', '<F10>', function() dap.step_over() end)        -- Step Over
      vim.keymap.set('n', '<F11>', function() dap.step_into() end)        -- Step Into
      vim.keymap.set('n', '<F12>', function() dap.step_out() end)         -- Step Out
      vim.keymap.set('n', '<Leader>b', function() dap.toggle_breakpoint() end) -- Toggle Breakpoint
      vim.keymap.set('n', '<Leader>B', function() dap.set_breakpoint() end)    -- Set Conditional Breakpoint
    end
  },

})
