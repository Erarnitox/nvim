vim.g.mapleader = " "

-- open the file explorer:
vim.keymap.set("n", "<leader>fe", vim.cmd.Ex)

-- some other settings
vim.opt.nu = true
vim.opt.relativenumber = false

vim.opt.mouse = "a"

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.numberwidth = 5

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.hlsearch = true 
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.showmatch = true
vim.opt.statusline = "%{FugitiveStatusline()} File:%f %m"
-- remaps

vim.keymap.set("i", "jj", "<ESC>")
vim.keymap.set("i", "hh", "#include <bits/stdc++.h>")

-- CTags stuff:
vim.keymap.set("n", "<leader>gd", "<C-]>")
vim.keymap.set("n", "<leader>e", ":Lex 15<CR>")

vim.keymap.set("n", "gt", ":BufferLineCycleNext<CR>")
vim.keymap.set("n", "gT", ":BufferLineCyclePrev<CR>")
vim.keymap.set("n", "<leader>zq", ":bdelete %<CR>")
vim.keymap.set("n", "<leader>zz", ":w <CR> :bdelete %<CR>")

vim.cmd [[packadd packer.nvim]]
return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.1',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }

  use {"akinsho/toggleterm.nvim", tag = '*', config = function()
        require("toggleterm").setup({
            size=20,
            open_mapping = "<leader><Space>",
            hide_numbers = true,
            shade_filetypes = {},
            shading_factor = 2,
            start_in_insert = true,
            insert_mappings = false,
            persist_size = true,
            direction = "float",
            close_on_exit = true,
            shell = vim.o.shell,
            float_opts = {
                border = "curved",
                winblend = 0,
                highlights = {
                    border = "Normal",
                    background = "Normal",
                }
            }
        })
    end}

  use('lewis6991/gitsigns.nvim')

  use 'martinsione/darkplus.nvim'
  use 'Mofiqul/vscode.nvim'
  use {'akinsho/bufferline.nvim', tag = "*", requires = 'nvim-tree/nvim-web-devicons'}

  use {
	'nvim-treesitter/nvim-treesitter',
	run = function()
		local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
		ts_update()
	end,}

  use("nvim-treesitter/nvim-treesitter-context");

  use("tpope/vim-fugitive");

  use('Civitasv/cmake-tools.nvim')

  use("nvim-lua/plenary.nvim")

  use {
	  'VonHeikemen/lsp-zero.nvim',
	  branch = 'v1.x',
	  requires = {
		  -- LSP Support
		  {'neovim/nvim-lspconfig'},
		  {'williamboman/mason.nvim'},
		  {'williamboman/mason-lspconfig.nvim'},

		  -- Autocompletion
		  {'hrsh7th/nvim-cmp'},
		  {'hrsh7th/cmp-buffer'},
		  {'hrsh7th/cmp-path'},
		  {'saadparwaiz1/cmp_luasnip'},
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'hrsh7th/cmp-nvim-lua'},

		  -- Snippets
		  {'L3MON4D3/LuaSnip'},
		  {'rafamadriz/friendly-snippets'},
	  }
  }
end)
