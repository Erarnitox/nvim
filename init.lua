-- Disable netrw as we use Telescope
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install lazy.nvim package manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath }
end
vim.opt.rtp:prepend(lazypath)

-- Plugins Setup
require('lazy').setup({
  -- Core Plugins for C++ Development
  
  -- LSP Configuration for C++
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',  -- LSP Installer
      'williamboman/mason-lspconfig.nvim', -- Auto LSP configuration
      'j-hui/fidget.nvim',        -- LSP status UI
      'folke/neodev.nvim',        -- Additional Lua config for Neovim
    },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup {
        ensure_installed = { 'clangd' }  -- C++ LSP
      }
      require('lspconfig').clangd.setup {
        on_attach = on_attach,
        capabilities = require('cmp_nvim_lsp').default_capabilities()
      }
    end
  },

  -- Autocompletion and Snippets
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',  -- Snippet engine
      'saadparwaiz1/cmp_luasnip', -- Snippet completion source
      'hrsh7th/cmp-nvim-lsp', -- LSP completion
    },
  },

  -- Debugger for C++ (DAP)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui", -- UI for DAP
      "jay-babu/mason-nvim-dap.nvim", -- Manage DAP installations
      'mfussenegger/nvim-nio', -- Required for nvim-dap-ui (handles async I/O)
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    end,
  },

  -- CMake integration
  'Civitasv/cmake-tools.nvim',

  -- Git Integration
  'tpope/vim-fugitive',

  -- Fuzzy Finder
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make', cond = function() return vim.fn.executable 'make' == 1 end,
      },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          file_ignore_patterns = { "node_modules", ".git", ".cache" }
        }
      }
    end
  },

  -- Syntax Highlighting with Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "cpp", "c", "lua" }, -- Languages to be installed
        highlight = { enable = true },
        textobjects = { select = { enable = true } },
      }
    end
  },

  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        theme = 'auto',
        section_separators = '',
        component_separators = '|',
      },
    },
  },

  -- Indentation and Blank Lines
  { 'lukas-reineke/indent-blankline.nvim' },

  -- Commenting plugin
  { 'numToStr/Comment.nvim', opts = {} },

  -- Git Signs in Gutter
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  'nvim-tree/nvim-web-devicons',  -- Icons for file types
  'nvim-treesitter/playground',  -- Treesitter playground for debugging
  'p00f/nvim-ts-rainbow', -- Rainbow parentheses
  'mbbill/undotree', -- Undo history
  'folke/tokyonight.nvim', -- Theme
  'VonHeikemen/lsp-zero.nvim', -- Easy LSP config
  'nvim-lua/plenary.nvim', -- Required dependency for some plugins
  'nvim-treesitter/nvim-treesitter-context', -- Sticky code context
  'simrat39/rust-tools.nvim', -- Rust support
  'sbdchd/neoformat', -- Formatting
  
  -- Additional helper plugins
  'tpope/vim-surround', -- Surround text objects
  -- 'windwp/nvim-autopairs', -- Auto close pairs
  'akinsho/toggleterm.nvim', -- Terminal Toggle Plugin
  'folke/which-key.nvim', -- Key binding helper

  -- File Explorer using oil.nvim
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup {
        view_options = {
          show_hidden = true,
        },
        keymaps = {
          ['g?'] = 'actions.show_help',
          ['<CR>'] = 'actions.select',
          ['<C-s>'] = 'actions.select_vsplit',
          ['<C-h>'] = 'actions.select_split',
          ['<C-t>'] = 'actions.select_tab',
          ['<C-p>'] = 'actions.preview',
          ['<C-c>'] = 'actions.close',
          ['q'] = 'actions.close',
          ['<C-r>'] = 'actions.refresh',
          ['-'] = 'actions.parent',
          ['_'] = 'actions.open_cwd',
        },
      }
    end
  }
}, {})

-- Set general Neovim options
vim.opt.termguicolors = true
vim.wo.number = true       -- Line numbers
vim.o.mouse = 'a'          -- Enable mouse
vim.o.clipboard = 'unnamedplus' -- Use system clipboard
vim.o.breakindent = true   -- Wrap lines with indent
vim.o.ignorecase = true    -- Case-insensitive search
vim.o.smartcase = true     -- Case-sensitive when capital letters used
vim.o.completeopt = 'menuone,noselect' -- Completion behavior

-- Keymap for 'jj' to exit insert mode
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Exit Insert Mode' })

-- ToggleTerm Configuration
require("toggleterm").setup {
  open_mapping = '<leader>tt', -- Toggle terminal with Ctrl-\
  direction = 'float', -- Use floating terminal
  float_opts = {
    border = 'curved', -- Curved border for floating terminal
  },
}

-- Set Keymaps (Including original keybindings)
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = 'Live Grep' })
vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, { desc = 'Find Buffers' })
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = 'Find Help' })
vim.keymap.set('n', '<leader>e', ':Oil<CR>', { desc = 'Toggle File Explorer (Oil)' }) -- Use Oil as the file explorer
vim.keymap.set('n', '<leader>u', ':UndotreeToggle<CR>', { desc = 'Toggle UndoTree' })

-- LSP Keymaps
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then desc = 'LSP: ' .. desc end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end
  nmap('gd', vim.lsp.buf.definition, 'Go to Definition')
  nmap('gr', require('telescope.builtin').lsp_references, 'Go to References')
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
end

