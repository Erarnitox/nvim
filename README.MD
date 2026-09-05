# NVIM — C++23 Configuration

Neovim setup oriented around modern C++ development with **clang**, **CMake**, **Ninja**, **CPM.cmake**, **git**, and **GitHub**.

You can use this config as-is or as a starting point. Back up your existing config first — the install command below replaces `~/.config/nvim`.

Based on ideas from [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).

## Installation

```sh
rm -rf ~/.config/nvim/
cd ~/.config/ && git clone https://github.com/Erarnitox/nvim
```

On first launch, [lazy.nvim](https://github.com/folke/lazy.nvim) installs plugins automatically. Run `:Lazy sync` if anything is missing.

### Prerequisites

| Tool | Role |
|------|------|
| `neovim` (≥ 0.10, tested on 0.12) | Editor |
| `clang` / `clang++` | Compiler (C++23) |
| `clangd` | Language server |
| `cmake` | Configure / generate |
| `ninja` | Build backend |
| `lldb` / `lldb-dap` | Debugger |
| `make` | Build telescope-fzf-native |
| `git` | VCS + fugitive |
| `ripgrep` (optional) | Faster Telescope live grep |
| `gh` (optional) | GitHub CLI |

## Features

- **clangd LSP** — background index, clang-tidy, IWYU header insertion, source/header switch; `compile_commands.json` wired via cmake-tools
- **CMake Tools** — Ninja + clang + C++23 defaults, soft-linked compile commands, ToggleTerm executor/runner, DAP via lldb
- **Light build helpers** — single-file compile/run and `cmake --build <repo>/build` for CPM projects that already have a `build/` tree
- **nvim-cmp** — LSP + snippet + path/buffer completion
- **nvim-dap + dap-ui** — breakpoints, stepping, UI; single-file launch or `CMakeDebug` for targets
- **Telescope** — files, grep, git files, diagnostics, TODOs (fzf-native when `make` is available)
- **Oil** — buffer-based file explorer
- **Git / GitHub** — fugitive, gitsigns, `:GBrowse` via rhubarb
- **Treesitter** — C/C++/CMake highlighting, textobjects, sticky context, C/C++ scope folds (`za`/`zc`/`zo`)
- **Kanagawa** theme, lualine, which-key, indent guides, Comment.nvim, undotree

## Typical CPM.cmake / GitHub workflow

1. Open the project root (`nvim .` or open any source file).
2. **`<leader>cg`** — `CMakeGenerate` (Ninja, clang, `CMAKE_EXPORT_COMPILE_COMMANDS`, C++23). CPM fetches deps into the build tree.
3. **`<leader>cb`** — `CMakeBuild`.
4. Edit with clangd (completions, `gd`, `gs` for header/source).
5. **`<leader>cs`** — pick the executable target if needed; **`<leader>cr`** to run or **`<leader>cd`** to debug.
6. **`<leader>gb`** — open the current file/line on GitHub (`:GBrowse`).

If `build/` already exists (e.g. from CI or a previous generate), **`mkg`** / **`<leader>mk`** runs `cmake --build <git-root>/build` without going through cmake-tools target selection.

For a one-off `.cpp` file (no CMake), use **`<leader>r`** (clang++ `-std=c++23`) or **`<leader>dc`** to compile with debug symbols and launch lldb.

## Plugins

**Core:** `nvim-lspconfig`, `mason.nvim`, `mason-lspconfig`, `fidget.nvim`, `nvim-cmp`, `LuaSnip`, `nvim-dap`, `nvim-dap-ui`, `cmake-tools.nvim`, `telescope.nvim`, `nvim-treesitter`, `toggleterm.nvim`, `oil.nvim`

**UI / editing:** `kanagawa.nvim`, `lualine.nvim`, `indent-blankline.nvim`, `which-key.nvim`, `todo-comments.nvim`, `Comment.nvim`, `vim-surround`, `undotree`, `nvim-treesitter-context`, `nvim-web-devicons`

**Git:** `vim-fugitive`, `vim-rhubarb`, `gitsigns.nvim`

## Keybindings

Leader is **Space**.

### General

| Keybind | Mode | Function |
|---------|------|----------|
| `jj` | Insert | Exit insert mode |
| `<leader>tt` | Normal | Toggle floating terminal |
| `<leader>e` | Normal | Toggle Oil explorer |
| `<leader>u` | Normal | UndoTree |
| `go` | Normal | Alternate file |
| `gn` / `gp` | Normal | Next / previous buffer |
| `<leader>ll` | Normal | Insert `//---` function header banner |
| `<leader>la` | Normal | Insert author/file/date/license header at top of C/C++ file |
| `za` / `zc` / `zo` | Normal | Toggle / close / open treesitter fold (C/C++) |
| `zM` / `zR` | Normal | Close / open all folds |
| `<leader>r` | Normal | Save + compile & run current C++ file |
| `mkg` / `<leader>mk` | Normal | `cmake --build <git-root>/build` |

### Telescope

| Keybind | Function |
|---------|----------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>ft` | TODOs |
| `<leader>gf` | Git files |
| `<leader>?` | Recent files |
| `<leader>/` | Fuzzy search in buffer |
| `<leader>h` | Diagnostics |

### LSP (buffer-local when clangd is attached)

| Keybind | Function |
|---------|----------|
| `gd` / `gD` | Definition / declaration |
| `gr` / `gi` | References / implementations |
| `gs` | Switch source ↔ header (clangd) |
| `K` / `<C-k>` | Hover / signature help |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `<leader>D` | Type definition |
| `<leader>ds` / `<leader>ws` | Document / workspace symbols |
| `<leader>lf` | Format buffer |
| `[d` / `]d` | Prev / next diagnostic |
| `<leader>i` | Float diagnostic |
| `<leader>q` | Toggle diagnostics location list |
| `<leader>td` | Toggle TODO location list |
| `<leader>ft` | Telescope TODOs (fuzzy) |

### CMake (`<leader>c`)

| Keybind | Function |
|---------|----------|
| `<leader>cg` | Generate |
| `<leader>cb` | Build |
| `<leader>cr` | Run |
| `<leader>cd` | Debug |
| `<leader>cs` | Select build target |
| `<leader>ct` | Select build type |
| `<leader>cc` | Clean |
| `<leader>cx` | Stop runner |

### Debug (`<leader>d`)

| Keybind | Function |
|---------|----------|
| `<leader>dc` | Continue / start |
| `<leader>do` / `di` / `dO` | Step over / into / out |
| `<leader>db` / `dB` | Toggle / conditional breakpoint |
| `<leader>dr` | Restart |
| `<leader>dq` | Terminate |
| `<leader>dl` | Run last |
| `<leader>du` | Toggle DAP UI |

### Git / GitHub

| Keybind | Function |
|---------|----------|
| `<leader>gs` | Fugitive status |
| `<leader>gb` | Open on GitHub (`:GBrowse`) |
| `<leader>hp` | Preview hunk |
| `]c` / `[c` | Next / previous hunk |

## Layout

Everything lives in a single [`init.lua`](init.lua): bootstrap → shared helpers / `on_attach` → `lazy.setup` → options → keymaps.
