" .gvimrc Configuration for C++ Development in GVim

" Disable netrw as we will use Telescope alternative
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

" Set leader key
let mapleader=" "
let maplocalleader=" "

" Plugin Manager Setup (vim-plug)
" Make sure to install vim-plug:
" https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')

" Plugin List

" LSP Support via CoC (Conquer of Completion)
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" C++ Debugging with Vimspector
Plug 'puremourning/vimspector'

" Fuzzy Finder with fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" CMake Integration
Plug 'cdelledonne/vim-cmake'

" Syntax Highlighting with vim-polyglot
Plug 'sheerun/vim-polyglot'

" Git Integration
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Statusline with Lightline
Plug 'itchyny/lightline.vim'

" Commenting
Plug 'tpope/vim-commentary'

" Indentation and Blankline visualization
Plug 'lukas-reineke/indent-blankline.nvim'

" Terminal Integration (GVim has a built-in terminal)
Plug 'kassio/neoterm'

" File Explorer alternative (NERDTree)
Plug 'preservim/nerdtree'

" Icons for file types (Devicons for NerdTree)
Plug 'ryanoasis/vim-devicons'

" Undo history (like undotree)
Plug 'mbbill/undotree'

" Color scheme (TokyoNight)
Plug 'folke/tokyonight.nvim'

call plug#end()

" Basic Settings
set number            " Show line numbers
set mouse=a           " Enable mouse usage
set clipboard=unnamedplus " Use system clipboard
set breakindent       " Enable break indent
set ignorecase        " Ignore case in search
set smartcase         " Case-sensitive search when capitals are used
set completeopt=menuone,noinsert,noselect " Better completion menu behavior
syntax on             " Syntax highlighting

" Color Scheme
colorscheme tokyonight

" LSP Setup (CoC)
let g:coc_global_extensions = ['coc-clangd', 'coc-json', 'coc-pyright']

" Key mappings for CoC (LSP)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> K :call CocAction('doHover')<CR>

" Autocomplete via CoC
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"

" Debugging with Vimspector
nmap <leader>dd :call vimspector#Launch()<CR>
nmap <leader>dc :call vimspector#Continue()<CR>
nmap <leader>dt :call vimspector#ToggleBreakpoint()<CR>

" Fuzzy Finder with fzf
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fh :Helptags<CR>

" NERDTree (File Explorer)
nmap <leader>e :NERDTreeToggle<CR>

" UndoTree
nmap <leader>u :UndotreeToggle<CR>

" Terminal Setup (Toggle terminal)
nmap <leader>tt :NeotermToggle<CR>

" Indentation and Blankline Configuration
let g:indent_blankline_enabled = v:true
let g:indent_blankline_char = '┆'
let g:indent_blankline_filetype_exclude = ['help', 'nerdtree']
let g:indent_blankline_buftype_exclude = ['terminal']

" GitGutter for git signs
set updatetime=1000  " Faster git gutter update
highlight GitGutterAdd guifg=#009900 ctermfg=2
highlight GitGutterChange guifg=#bbbb00 ctermfg=3
highlight GitGutterDelete guifg=#ff2222 ctermfg=1

" Commenting Plugin (Vim Commentary)
" Use gcc to comment/uncomment lines

" NERDTree Configuration
let g:NERDTreeShowHidden=1
let g:NERDTreeIgnore=['\.git$', 'node_modules$']

" Lightline Configuration
set noshowmode " Don't show the default mode in statusline
let g:lightline = {
      \ 'colorscheme': 'tokyonight',
      \ }

" Keymapping for 'jj' to exit insert mode
inoremap jj <Esc>

" LSP Statusline integration (for Lightline)
function! CocStatus() abort
  return coc#status()
endfunction
set statusline+=%{CocStatus()}

" Additional Keymappings
nnoremap <leader>e :NERDTreeToggle<CR>
nnoremap <leader>u :UndotreeToggle<CR>

" Git Integration keymaps (GitGutter)
nmap <leader>hs :Gwrite<CR>  " Stage the current file
nmap <leader>hu :Gread<CR>   " Undo changes in the current file
nmap <leader>hp :GitGutterPreviewHunk<CR> " Preview git changes
nmap <leader>hd :GitGutterDiffOrig<CR>    " Show file diff

" Save changes with :w
nnoremap <leader>w :w<CR>

" Exit Vim
nnoremap <leader>q :q<CR>
