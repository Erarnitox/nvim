# NVIM - Configuration

This is my nvim setup I use for programming primarily in C++.
You can either use this config as is, or use it as a starting point
for your own configuration.

I switched to using kickstart.nvim as a base. Thanks a lot to them for providing it!

It should also be noted that you should back up your old confing as the following command will delete your old one.

## Installation:
> `rm -rf ~/.config/nvim/ && cd ~/.config/ && git clone https://github.com/Erarnitox/nvim`

This is a Neovim configuration optimized for C++ development, with integrated tools for LSP, debugging, file exploration, and terminal management.

## Features

- **C++ Language Server Support**: Configured with `clangd` using `nvim-lspconfig`, with `mason.nvim` for installation and management of LSP servers.
- **Autocompletion**: Provided by `nvim-cmp` and `LuaSnip` for snippets.
- **Debugging**: Integrated with `nvim-dap` and `nvim-dap-ui` for managing breakpoints, stepping through code, and inspecting variables.
- **Fuzzy Finder**: `telescope.nvim` with `fzf-native` for efficient file searching and text grepping.
- **Treesitter**: Configured for C++, Lua, and C with enhanced syntax highlighting and text object selection.
- **File Explorer**: Using `oil.nvim` for a more modern and streamlined file browsing experience.
- **Integrated Terminal**: `toggleterm.nvim` for quickly toggling a terminal within Neovim.
- **Git Integration**: `vim-fugitive` and `gitsigns.nvim` for seamless git integration.
- **Indentation and Blank Line Indicators**: `indent-blankline.nvim` for visual indentation guides.

## Plugin List

- **Core Plugins**:
  - `neovim/nvim-lspconfig`
  - `mfussenegger/nvim-dap`
  - `hrsh7th/nvim-cmp`
  - `nvim-treesitter/nvim-treesitter`
  - `akinsho/toggleterm.nvim`
  - `stevearc/oil.nvim`

- **UI and Enhancement Plugins**:
  - `lukas-reineke/indent-blankline.nvim`
  - `nvim-lualine/lualine.nvim`
  - `numToStr/Comment.nvim`
  - `lewis6991/gitsigns.nvim`
  - `p00f/nvim-ts-rainbow`
  - `mbbill/undotree`
  - `folke/tokyonight.nvim`

## Keybindings

The following table provides a summary of the keybindings configured in this setup:

| Keybind             | Mode     | Function                              |
|---------------------|----------|---------------------------------------|
| `<leader>ff`        | Normal   | Open Telescope to find files          |
| `<leader>fg`        | Normal   | Live grep using Telescope             |
| `<leader>fb`        | Normal   | Find open buffers with Telescope      |
| `<leader>fh`        | Normal   | Find help tags with Telescope         |
| `<leader>e`         | Normal   | Open Oil file explorer                |
| `<leader>u`         | Normal   | Toggle UndoTree view                  |
| `<leader>tt`        | Normal   | Toggle floating terminal (ToggleTerm) |
| `jj`                | Insert   | Exit insert mode                      |
| `gd`                | Normal   | Go to definition (LSP)                |
| `gr`                | Normal   | Go to references (Telescope + LSP)    |
| `K`                 | Normal   | Hover documentation (LSP)             |
