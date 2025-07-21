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
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        cmd = { "clangd", "--clang-tidy" }
      }
    end
  },

  -- Autocomplete
  {
    'hrsh7th/nvim-cmp',        -- Autocompletion plugin
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',  -- LSP source for nvim-cmp
      'hrsh7th/cmp-buffer',    -- Buffer source
      'hrsh7th/cmp-path',      -- Path source
      'hrsh7th/cmp-cmdline',   -- Command-line source
      'saadparwaiz1/cmp_luasnip', -- Snippet source
      'L3MON4D3/LuaSnip',      -- Snippet engine
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        }),
      }

      -- Use buffer and path suggestions for `/` and `:` commands
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })
    end
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
  'rebelot/kanagawa.nvim', -- Theme
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
        default_file_explorer = false,
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

-- Add a Simple function Signature
_G.insert_function_header = function()
  local line_num = vim.fn.line('.') - 1
  local comment = { "//----------------------------------------", "//", "//----------------------------------------" }
  vim.api.nvim_buf_set_lines(0, line_num, line_num, false, comment)
end

vim.api.nvim_set_keymap('n', '<leader>ll', ':lua insert_function_header()<CR>', { noremap = true, silent = true })

-- Set Keymaps (Including original keybindings)
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = 'Live Grep' })
vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, { desc = 'Find Buffers' })
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = 'Find Help' })

vim.keymap.set('n', '<leader>e',  function()
	if vim.bo.filetype == "oil" then
		require('oil').close()
	else
		require('oil').open()
	end
end, { desc = 'Toggle File Explorer (Oil)' })

vim.keymap.set('n', '<leader>u', ':UndotreeToggle<CR>', { desc = 'Toggle UndoTree' })

vim.keymap.set('n', 'go', ':e#<CR>', { desc = 'Goto previous file' })
vim.keymap.set('n', 'gn', ':bnext<CR>', { desc = "Next Buffer" });
vim.keymap.set('n', 'gp', ':bprevious<CR>', { desc = "Previous Buffer" });

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

-- Default options:
require('kanagawa').setup({
    compile = false,             -- enable compiling the colorscheme
    undercurl = true,            -- enable undercurls
    commentStyle = { italic = true },
    functionStyle = {},
    keywordStyle = { italic = true},
    statementStyle = { bold = true },
    typeStyle = {},
    transparent = false,         -- do not set background color
    dimInactive = false,         -- dim inactive window `:h hl-NormalNC`
    terminalColors = true,       -- define vim.g.terminal_color_{0,17}
    colors = {                   -- add/modify theme and palette colors
        palette = {},
        theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
    },
    overrides = function(colors) -- add/modify highlights
        return {}
    end,
    theme = "wave",              -- Load "wave" theme when 'background' option is not set
    background = {                 -- map the value of 'background' option to a theme
        dark = "wave",           -- try "dragon" !
        light = "lotus"
    },
})

_G.compile_cmake_global = function()
    local compile_cmd = "cmake --build `git rev-parse --show-toplevel 2>/dev/null`/build"

    require("toggleterm.terminal").Terminal:new({
        cmd = compile_cmd,
        direction = "float",
        close_on_exit = false,
    }):toggle()
end

_G.compile_and_run_cpp = function()
    local filepath = vim.fn.expand("%:p")
    local filename = vim.fn.expand("%:t:r") -- Get the file name without extension
    local output = "/tmp/" .. filename      -- Temporary output file path

    local compile_cmd = "clang++ -std=c++23 -o " .. output .. " " .. filepath .. " && " .. output

    require("toggleterm.terminal").Terminal:new({
        cmd = compile_cmd,
        direction = "float",
        close_on_exit = false,
    }):toggle()
end

local dap = require("dap")
local dapui = require("dapui")

dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-dap',
  name = 'lldb'
}

dap.configurations.cpp = {
  {
    name = "Launch",
    type = "lldb",
    request = "launch",
    program = function()
      local filepath = vim.fn.expand("%:p")
      local filename = vim.fn.expand("%:t:r") 
      local output = "/tmp/" .. filename
      local compile_cmd = string.format("clang++ -std=c++23 -g -o %s %s", output, filepath)

      local result = os.execute(compile_cmd)
      if result ~= 0 then
        print("Compilation failed!")
        return nil
      end

      print("Compiled successfully:", output)
      return output
    end,
    cwd = '${workspaceFolder}',
    stopAtEntry = true,
    args = {},
    runInTerminal = false,
    setupCommands = {
      {
        description = "Enable pretty printing",
        text = "-enable-pretty-printing",
        ignoreFailures = false
      }
    },
  }
}

dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap('n', '<leader>do', '<Cmd>lua require("dap").step_over()<CR>', { noremap = true, silent = true, desc = 'Step Over' })
vim.api.nvim_set_keymap('n', '<leader>di', '<Cmd>lua require("dap").step_into()<CR>', { noremap = true, silent = true, desc = 'Step Into' })
vim.api.nvim_set_keymap('n', '<leader>du', '<Cmd>lua require("dap").step_out()<CR>', { noremap = true, silent = true, desc = 'Step Out' })
vim.api.nvim_set_keymap('n', '<leader>db', '<Cmd>lua require("dap").toggle_breakpoint()<CR>', { noremap = true, silent = true, desc = 'Toggle Breakpoint' })
vim.api.nvim_set_keymap('n', '<leader>dr', '<Cmd>lua require("dap").restart()<CR>', { noremap = true, silent = true, desc = 'Restart Debugging' })
vim.api.nvim_set_keymap('n', '<leader>dq', '<Cmd>lua require("dap").terminate()<CR>', { noremap = true, silent = true, desc = 'Stop Debugging' })
vim.api.nvim_set_keymap('n', '<Leader>dl', ':lua require"dap".run_last()<CR>', opts) 

vim.api.nvim_set_keymap("n", "<leader>r", ":w<CR>:lua compile_and_run_cpp()<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "mkg", ":w<CR>:lua compile_cmake_global()<CR>", { noremap = true, silent = true })

-- set tab = 2 spaces
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- setup must be called before loading
vim.cmd("colorscheme kanagawa")
