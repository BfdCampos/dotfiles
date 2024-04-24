" Auto install vim-plug if not installed
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Set line numbers and relative line numbers
set number
set relativenumber

" Enable auto-indentation
set autoindent

" Set tab settings
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab

" Disable mouse support
set mouse=

" Open split windows below
set splitbelow

" Begin Plug configuration
call plug#begin()

Plug 'APZelos/blamer.nvim' " GitLens to see who wrote which a piece of code
Plug 'http://github.com/tpope/vim-surround' " vim-surround for surrounding characters
Plug 'https://github.com/preservim/nerdtree' " NerdTree
Plug 'https://github.com/tpope/vim-commentary' " vim-commentary for commenting code
Plug 'https://github.com/vim-airline/vim-airline' " vim-airline for a status bar
Plug 'https://github.com/lifepillar/pgsql.vim' " pgsql.vim for PSQL plugin
Plug 'https://github.com/ap/vim-css-color' " vim-css-color for CSS color preview
Plug 'https://github.com/rafi/awesome-vim-colorschemes' " awesome-vim-colorschemes for retro scheme
Plug 'https://github.com/ryanoasis/vim-devicons' " vim-devicons for developer icons
Plug 'https://github.com/tc50cal/vim-terminal' " vim-terminal
Plug 'https://github.com/preservim/tagbar' " tagbar for code navigation
Plug 'https://github.com/terryma/vim-multiple-cursors' " vim-multiple-cursors
Plug 'github/copilot.vim' " copilot.vim for Git-Copilot integration
Plug 'sheerun/vim-polyglot' " vim-polyglot for language packs
Plug 'pangloss/vim-javascript' " vim-javascript for JavaScript syntax highlighting
Plug 'maxmellon/vim-jsx-pretty' " vim-jsx-pretty for JSX syntax highlighting
Plug 'hashivim/vim-terraform' " vim-terraform for Terraform syntax highlighting
Plug 'takac/vim-hardtime' " hardtime.nvim for preventing h,j,k,l spamming
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " fzf for fuzzy finding
Plug 'junegunn/fzf.vim' " fzf.vim for fuzzy finding
Plug 'elzr/vim-json' " vim-json for JSON syntax highlighting
Plug 'Yggdroot/indentLine' " indentLine for indentation lines
Plug 'neoclide/coc.nvim', {'branch': 'release'} " coc.nvim for autocompletion
Plug 'nightsense/vimspectr' " vimspectr for color preview

" End Plug configuration
call plug#end()

" Customize :Rg command for fzf.vim to search hidden files, ignore .gitignore and include preview
command! -bang -nargs=* Rg
     \ call fzf#vim#grep('rg --hidden --no-ignore --follow --color=always --line-number --column '.shellescape(<q-args>), 1, 
     \ fzf#vim#with_preview(), <bang>0)

" NERDTree mappings
nnoremap <C-f> :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>

" New mapping for fzf.vim
nnoremap <C-p> :Files<CR>
nnoremap <C-g> :Rg<CR>
" You need to have ripgrep installed for this to work (brew install ripgrep)

" Auto replace all highlight text
vnoremap <C-r> "hy:%s/<C-r>h//g<left><left>

" Terminal mappings
tnoremap <Esc> <C-\><C-n>

" Tagbar mappings
nmap <F8> :TagbarToggle<CR>

" Disable preview for autocomplete
set completeopt-=preview

" Set background to transparent
let g:onedark_color_overrides = {
\ "background": {"gui": "NONE", "cterm": "NONE", "cterm16": "NONE"}
\}

" Set colorscheme
colorscheme onedark

" NERDTree configuration
let g:NERDTreeDirArrowExpandable="+"
let g:NERDTreeDirArrowCollapsible="-"
let NERDTreeShowHidden=1
let g:NERDTreeWinSize = 40

" Blamer configuration
let g:blamer_enabled=1
let g:blamer_show_in_insert_more=0
let g:blamer_prefix=' <-- '

" HardTime config
let g:hardtime_showmsg = 1

autocmd FileType tagbar call TagbarOpenZsh()

" javascript indenting
autocmd BufNewFile,BufRead *.js,*.jsx setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
