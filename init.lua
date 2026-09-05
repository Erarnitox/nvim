-- =============================================================================
-- Neovim config optimized for modern C++23 (clang, CMake, Ninja, CPM, GitHub)
-- =============================================================================

-- === Bootstrap ===============================================================

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- === Shared helpers (must exist before lazy plugin configs) ==================

local function shellescape(path)
  return vim.fn.shellescape(path)
end

local function git_toplevel()
  local root = vim.fn.systemlist('git rev-parse --show-toplevel 2>/dev/null')[1]
  if root and root ~= '' and vim.fn.isdirectory(root) == 1 then
    return root
  end
  return vim.fn.getcwd()
end

--- Single-file compile + run (scratch / interview / small utils).
local function compile_and_run_cpp()
  local filepath = vim.fn.expand '%:p'
  if filepath == '' or not filepath:match '%.[cC][pP]?[pPxX]?$' then
    vim.notify('Not a C/C++ source file', vim.log.levels.WARN)
    return
  end

  local filename = vim.fn.expand '%:t:r'
  local output = '/tmp/' .. filename
  local compile_cmd = table.concat({
    'clang++',
    '-std=c++23',
    '-Wall',
    '-Wextra',
    '-g',
    '-o',
    shellescape(output),
    shellescape(filepath),
    '&&',
    shellescape(output),
  }, ' ')

  require('toggleterm.terminal').Terminal:new({
    cmd = compile_cmd,
    direction = 'float',
    close_on_exit = false,
  }):toggle()
end

--- Quick cmake --build <repo>/build (Ninja-friendly; for already-configured CPM trees).
local function compile_cmake_global()
  local root = git_toplevel()
  local build_dir = root .. '/build'
  if vim.fn.isdirectory(build_dir) == 0 then
    vim.notify(
      'No build/ directory at ' .. build_dir .. ' — run <leader>cg (CMakeGenerate) first',
      vim.log.levels.WARN
    )
    return
  end

  local compile_cmd = 'cmake --build ' .. shellescape(build_dir)
  require('toggleterm.terminal').Terminal:new({
    cmd = compile_cmd,
    direction = 'float',
    close_on_exit = false,
  }):toggle()
end

local function insert_function_header()
  local line_num = vim.fn.line '.' - 1
  local comment = {
    '//----------------------------------------',
    '//',
    '//----------------------------------------',
  }
  vim.api.nvim_buf_set_lines(0, line_num, line_num, false, comment)
end

local function insert_author_header()
  local filename = vim.fn.expand '%:t'
  local ft = vim.bo.filetype
  local is_cpp = ft == 'cpp' or ft == 'c' or ft == 'cuda'
    or filename:match '%.[cC][pP]?[pPxX]?$'
    or filename:match '%.[hH][pP]?[pPxX]?$'
  if not is_cpp then
    vim.notify('Not a C/C++ source file', vim.log.levels.WARN)
    return
  end

  if filename == '' then
    filename = 'untitled'
  end

  local rev = 'n/a'
  local buf_dir = vim.fn.expand '%:p:h'
  if buf_dir ~= '' then
    local out = vim.fn.systemlist({
      'git',
      '-C',
      buf_dir,
      'rev-parse',
      '--short',
      'HEAD',
    })
    if vim.v.shell_error == 0 and out[1] and out[1] ~= '' then
      rev = out[1]
    end
  end

  local date = os.date '%Y-%m-%d'
  local year = os.date '%Y'
  local comment = {
    '//----------------------------------------',
    '// File:      ' .. filename,
    '// Author:    erarnitox - David Partsch',
    '// Email:     david@erarnitox.de',
    '// Website:   https://erarnitox.de',
    '// Copyright: (c) ' .. year .. ' David Partsch',
    '// License:   Proprietary. All rights reserved.',
    '// Date:      ' .. date,
    '// Revision:  ' .. rev,
    '//----------------------------------------',
    '',
  }
  vim.api.nvim_buf_set_lines(0, 0, 0, false, comment)
end

--- True if the current window's location-list window is open.
local function loclist_is_open()
  return vim.fn.getloclist(0, { winid = 0 }).winid ~= 0
end

local function loclist_title()
  return vim.fn.getloclist(0, { title = 0 }).title or ''
end

local function toggle_diagnostics_list()
  if loclist_is_open() and loclist_title():lower():find('diagnostic', 1, true) then
    vim.cmd.lclose()
    return
  end
  vim.diagnostic.setloclist { open = true }
end

local function toggle_todo_list()
  if loclist_is_open() and loclist_title() == 'Todo' then
    vim.cmd.lclose()
    return
  end
  vim.cmd.TodoLocList()
end

local on_attach = function(client, bufnr)
  local nmap = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end

  nmap('gd', vim.lsp.buf.definition, 'Go to Definition')
  nmap('gD', vim.lsp.buf.declaration, 'Go to Declaration')
  nmap('gr', require('telescope.builtin').lsp_references, 'Go to References')
  nmap('gi', require('telescope.builtin').lsp_implementations, 'Go to Implementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type Definition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')
  nmap('<leader>rn', vim.lsp.buf.rename, 'Rename')
  nmap('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Help')
  nmap('<leader>lf', function()
    vim.lsp.buf.format { async = true }
  end, 'Format Buffer')

  -- clangd: toggle between .cpp / .h(.hpp)
  if client.name == 'clangd' then
    nmap('gs', function()
      local method = 'textDocument/switchSourceHeader'
      if not client:supports_method(method) then
        vim.notify('clangd does not support switchSourceHeader', vim.log.levels.WARN)
        return
      end
      local params = vim.lsp.util.make_text_document_params(bufnr)
      client:request(method, params, function(err, result)
        if err then
          vim.notify(tostring(err), vim.log.levels.ERROR)
          return
        end
        if not result then
          vim.notify('Corresponding source/header not found', vim.log.levels.INFO)
          return
        end
        vim.cmd.edit(vim.uri_to_fname(result))
      end, bufnr)
    end, 'Switch Source/Header')
  end
end

-- === Plugins =================================================================

require('lazy').setup({
  -- --- LSP -------------------------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Ensure clangd is installed; mason-lspconfig auto-enables via vim.lsp.enable()
      require('mason-lspconfig').setup {
        ensure_installed = { 'clangd' },
        automatic_enable = true,
      }

      -- Neovim 0.11+ native LSP config (merges with nvim-lspconfig's lsp/clangd.lua)
      vim.lsp.config('clangd', {
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--header-insertion=iwyu',
          '--completion-style=detailed',
          '--function-arg-placeholders',
          '--fallback-style=llvm',
        },
        capabilities = capabilities,
        on_attach = on_attach,
        -- Point clangd at cmake-tools build dir when soft_link is not enough
        before_init = function(_, config)
          local ok, cmake = pcall(require, 'cmake-tools')
          if ok and cmake.clangd_on_new_config then
            cmake.clangd_on_new_config(config)
          end
        end,
      })
      vim.lsp.enable 'clangd'
    end,
  },

  -- --- Completion ------------------------------------------------------------
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'saadparwaiz1/cmp_luasnip',
      'L3MON4D3/LuaSnip',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm { select = true },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        }),
      }

      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = 'buffer' } },
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } }),
      })
    end,
  },

  -- --- DAP -------------------------------------------------------------------
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'rcarriga/nvim-dap-ui',
      'jay-babu/mason-nvim-dap.nvim',
    },
    keys = {
      { '<leader>dc', desc = 'Debug: Continue' },
      { '<leader>db', desc = 'Debug: Toggle Breakpoint' },
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('mason-nvim-dap').setup {
        ensure_installed = {},
        automatic_installation = false,
        handlers = {},
      }

      dapui.setup()
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end

      dap.adapters.lldb = {
        type = 'executable',
        command = '/usr/bin/lldb-dap',
        name = 'lldb',
      }

      dap.configurations.cpp = {
        {
          name = 'Launch current file',
          type = 'lldb',
          request = 'launch',
          program = function()
            local filepath = vim.fn.expand '%:p'
            local filename = vim.fn.expand '%:t:r'
            local output = '/tmp/' .. filename
            local compile_cmd = string.format(
              'clang++ -std=c++23 -Wall -Wextra -g -o %s %s',
              shellescape(output),
              shellescape(filepath)
            )
            local result = os.execute(compile_cmd)
            -- os.execute returns an exit status; treat any non-zero as failure
            if not result or result ~= 0 then
              vim.notify('Compilation failed', vim.log.levels.ERROR)
              return nil
            end
            return output
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
      }
      dap.configurations.c = dap.configurations.cpp
    end,
  },

  -- --- CMake -----------------------------------------------------------------
  {
    'Civitasv/cmake-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    lazy = false,
    config = function()
      require('cmake-tools').setup {
        cmake_command = 'cmake',
        ctest_command = 'ctest',
        cmake_use_preset = true,
        cmake_regenerate_on_save = true,
        cmake_generate_options = {
          '-G',
          'Ninja',
          '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON',
          '-DCMAKE_C_COMPILER=clang',
          '-DCMAKE_CXX_COMPILER=clang++',
          '-DCMAKE_CXX_STANDARD=23',
        },
        cmake_build_options = {},
        cmake_build_directory = 'build',
        cmake_compile_commands_options = {
          action = 'soft_link',
          target = vim.uv.cwd,
        },
        cmake_dap_configuration = {
          name = 'cpp',
          type = 'lldb',
          request = 'launch',
          stopOnEntry = false,
          runInTerminal = true,
        },
        cmake_executor = {
          name = 'toggleterm',
          opts = {},
          default_opts = {
            toggleterm = {
              direction = 'float',
              close_on_exit = false,
              auto_scroll = true,
              singleton = true,
            },
          },
        },
        cmake_runner = {
          name = 'toggleterm',
          opts = {},
          default_opts = {
            toggleterm = {
              direction = 'float',
              close_on_exit = false,
              auto_scroll = true,
              singleton = true,
            },
          },
        },
      }
    end,
  },

  -- --- Git -------------------------------------------------------------------
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
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
      on_attach = function(bufnr)
        local gs = require 'gitsigns'
        vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Next git hunk' })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Previous git hunk' })
      end,
    },
  },

  -- --- Fuzzy finder ----------------------------------------------------------
  {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          file_ignore_patterns = {
            'node_modules',
            '.git/',
            '.cache',
            'build/',
            '%.o',
            '%.a',
            '%.so',
            '%.dylib',
          },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
    end,
  },

  -- --- Treesitter ------------------------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local parsers = {
        'cpp',
        'c',
        'cmake',
        'lua',
        'vim',
        'vimdoc',
        'query',
        'markdown',
        'markdown_inline',
      }
      require('nvim-treesitter').install(parsers)
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          local ok = pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          local ft = ev.match
          if ok and (ft == 'cpp' or ft == 'c' or ft == 'cuda') then
            -- Window-local treesitter folds for C-family scopes (functions, classes, …)
            vim.wo[0][0].foldmethod = 'expr'
            vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            vim.wo[0][0].foldtext = ''
          end
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = { lookahead = true },
      }
      local select = require('nvim-treesitter-textobjects.select').select_textobject
      for keys, capture in pairs {
        af = '@function.outer',
        ['if'] = '@function.inner',
        ac = '@class.outer',
        ic = '@class.inner',
      } do
        vim.keymap.set({ 'x', 'o' }, keys, function()
          select(capture, 'textobjects')
        end)
      end
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = { max_lines = 3 },
  },

  -- --- UI --------------------------------------------------------------------
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'auto',
        section_separators = '',
        component_separators = '|',
      },
    },
  },
  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },
  {
    'lukas-reineke/virt-column.nvim',
    opts = {
      char = { '│', '│' },
      virtcolumn = '80,120',
      -- Index 1 → column 80, index 2 → column 120 (plugin sorts columns descending)
      highlight = { 'VirtColumnWarn', 'VirtColumnError' },
    },
    config = function(_, opts)
      local function set_virt_column_hls()
        vim.api.nvim_set_hl(0, 'VirtColumnWarn', { fg = '#e6c07b' }) -- yellow @ 80
        vim.api.nvim_set_hl(0, 'VirtColumnError', { fg = '#e06c75' }) -- red @ 120
      end
      set_virt_column_hls()
      vim.api.nvim_create_autocmd('ColorScheme', {
        desc = 'Keep virt-column 80/120 guide colors',
        callback = set_virt_column_hls,
      })
      require('virt-column').setup(opts)
    end,
  },
  { 'numToStr/Comment.nvim', opts = {} },
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      spec = {
        { '<leader>c', group = 'CMake' },
        { '<leader>d', group = 'Debug' },
        { '<leader>f', group = 'Find' },
        { '<leader>g', group = 'Git' },
        { '<leader>h', group = 'Diagnostics / Hunk' },
        { '<leader>l', group = 'LSP helpers' },
        { '<leader>t', group = 'Lists / Terminal' },
      },
    },
  },
  'nvim-tree/nvim-web-devicons',
  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('kanagawa').setup {
        compile = false,
        undercurl = true,
        commentStyle = { italic = true },
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        transparent = false,
        dimInactive = false,
        terminalColors = true,
        theme = 'wave',
        background = {
          dark = 'wave',
          light = 'lotus',
        },
      }
      vim.cmd.colorscheme 'kanagawa'
    end,
  },

  -- --- Editing / files / terminal --------------------------------------------
  'tpope/vim-surround',
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = { { '<leader>u', '<cmd>UndotreeToggle<CR>', desc = 'Toggle UndoTree' } },
  },
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {
      open_mapping = [[<leader>tt]],
      direction = 'float',
      float_opts = { border = 'curved' },
    },
  },
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup {
        default_file_explorer = true,
        view_options = { show_hidden = true },
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
    end,
  },
}, {
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})

-- === Options =================================================================

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.completeopt = 'menuone,noselect'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 4
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.foldenable = true
vim.opt.foldlevelstart = 99 -- open files with folds expanded; use za/zc/zo to toggle

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- === Keymaps =================================================================

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Exit insert mode' })

-- Buffers / navigation
vim.keymap.set('n', 'go', '<C-^>', { desc = 'Goto alternate file' })
vim.keymap.set('n', 'gn', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', 'gp', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })

-- Diagnostics
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
vim.keymap.set('n', '<leader>h', require('telescope.builtin').diagnostics, { desc = 'Telescope diagnostics' })
vim.keymap.set('n', '<leader>i', vim.diagnostic.open_float, { desc = 'Line diagnostics' })
vim.keymap.set('n', '<leader>q', toggle_diagnostics_list, { desc = 'Toggle diagnostics list' })
vim.keymap.set('n', '<leader>td', toggle_todo_list, { desc = 'Toggle TODO list' })

-- Telescope
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = 'Find help' })
vim.keymap.set('n', '<leader>ft', '<cmd>TodoTelescope<CR>', { desc = 'Find TODOs' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Git files' })
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = 'Recent files' })
vim.keymap.set('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(
    require('telescope.themes').get_dropdown { winblend = 10, previewer = false }
  )
end, { desc = 'Fuzzy search in buffer' })

-- Oil
vim.keymap.set('n', '<leader>e', function()
  if vim.bo.filetype == 'oil' then
    require('oil').close()
  else
    require('oil').open()
  end
end, { desc = 'Toggle Oil file explorer' })

-- Helpers
vim.keymap.set('n', '<leader>ll', insert_function_header, { desc = 'Insert function header banner' })
vim.keymap.set('n', '<leader>la', insert_author_header, { desc = 'Insert author file header' })
vim.keymap.set('n', '<leader>r', function()
  vim.cmd.write()
  compile_and_run_cpp()
end, { desc = 'Compile & run current C++ file' })
vim.keymap.set('n', 'mkg', function()
  vim.cmd.write()
  compile_cmake_global()
end, { desc = 'cmake --build <git-root>/build' })
vim.keymap.set('n', '<leader>mk', function()
  vim.cmd.write()
  compile_cmake_global()
end, { desc = 'cmake --build <git-root>/build' })

-- CMake Tools
vim.keymap.set('n', '<leader>cg', '<cmd>CMakeGenerate<CR>', { desc = 'CMake: Generate' })
vim.keymap.set('n', '<leader>cb', '<cmd>CMakeBuild<CR>', { desc = 'CMake: Build' })
vim.keymap.set('n', '<leader>cr', '<cmd>CMakeRun<CR>', { desc = 'CMake: Run' })
vim.keymap.set('n', '<leader>cd', '<cmd>CMakeDebug<CR>', { desc = 'CMake: Debug' })
vim.keymap.set('n', '<leader>cs', '<cmd>CMakeSelectBuildTarget<CR>', { desc = 'CMake: Select target' })
vim.keymap.set('n', '<leader>ct', '<cmd>CMakeSelectBuildType<CR>', { desc = 'CMake: Select build type' })
vim.keymap.set('n', '<leader>cc', '<cmd>CMakeClean<CR>', { desc = 'CMake: Clean' })
vim.keymap.set('n', '<leader>cx', '<cmd>CMakeStopRunner<CR>', { desc = 'CMake: Stop runner' })

-- DAP
vim.keymap.set('n', '<leader>dc', function()
  require('dap').continue()
end, { desc = 'Debug: Continue' })
vim.keymap.set('n', '<leader>do', function()
  require('dap').step_over()
end, { desc = 'Debug: Step over' })
vim.keymap.set('n', '<leader>di', function()
  require('dap').step_into()
end, { desc = 'Debug: Step into' })
vim.keymap.set('n', '<leader>dO', function()
  require('dap').step_out()
end, { desc = 'Debug: Step out' })
vim.keymap.set('n', '<leader>db', function()
  require('dap').toggle_breakpoint()
end, { desc = 'Debug: Toggle breakpoint' })
vim.keymap.set('n', '<leader>dB', function()
  require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
end, { desc = 'Debug: Conditional breakpoint' })
vim.keymap.set('n', '<leader>dr', function()
  require('dap').restart()
end, { desc = 'Debug: Restart' })
vim.keymap.set('n', '<leader>dq', function()
  require('dap').terminate()
end, { desc = 'Debug: Terminate' })
vim.keymap.set('n', '<leader>dl', function()
  require('dap').run_last()
end, { desc = 'Debug: Run last' })
vim.keymap.set('n', '<leader>du', function()
  require('dapui').toggle()
end, { desc = 'Debug: Toggle UI' })

-- Git / GitHub
vim.keymap.set('n', '<leader>gs', '<cmd>Git<CR>', { desc = 'Git status (fugitive)' })
vim.keymap.set('n', '<leader>gb', '<cmd>GBrowse<CR>', { desc = 'Open on GitHub' })
vim.keymap.set('v', '<leader>gb', ":'<,'>GBrowse<CR>", { desc = 'Open selection on GitHub' })
