nnoremap <C-s> :write<CR>
inoremap <C-s> <Esc>:write<CR>a
vnoremap <C-s> <Esc>:write<CR>gv
nnoremap <C-q> :quit<CR>
nnoremap <C-t> :echo strftime("%H:%M")<CR>
inoremap <C-t> <Esc>:echo strftime("%H:%M")<CR>a
vnoremap <C-t> <Esc>:echo strftime("%H:%M")<CR>gv
filetype plugin indent on
syntax on
function! SmartOpen(open, close, multiline) abort
    let l:next = strpart(getline('.'), col('.') - 1, 1)

    " Si el cierre ya existe delante, insertar solo la apertura
    if l:next ==# a:close
        return a:open
    endif

    " Bloque multilínea para llaves
    if a:multiline
        return a:open . "\<CR>" . a:close . "\<Esc>O\<C-t>"
    endif

    " Par normal
    return a:open . a:close . "\<Left>"
endfunction

inoremap <expr> ( SmartOpen('(', ')', 0)
inoremap <expr> [ SmartOpen('[', ']', 0)
inoremap <expr> { SmartOpen('{', '}', 1)
inoremap <expr> ) getline('.')[col('.') - 1] ==# ')' ? "\<Right>" : ')'
inoremap <expr> ] getline('.')[col('.') - 1] ==# ']' ? "\<Right>" : ']'
inoremap <expr> } getline('.')[col('.') - 1] ==# '}' ? "\<Right>" : '}'
highlight MatchParen ctermfg=Cyan ctermbg=NONE cterm=bold
set autoindent
set shiftwidth=4
set softtabstop=4
set expandtab
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_completeopt = 0
set completeopt=menuone,noinsert,noselect
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
imap <C-Space> <Plug>(asyncomplete_force_refresh)
let g:lsp_diagnostics_virtual_text_enabled = 1
let g:lsp_diagnostics_virtual_text_align = 'after'
let g:lsp_diagnostics_virtual_text_prefix = '  -> '
let g:lsp_diagnostics_virtual_text_wrap = 'truncate'
let g:lsp_diagnostics_virtual_text_tidy = 1
let g:lsp_diagnostics_highlight_enabled = 0
let g:lsp_diagnostics_signs_enabled = 0
if executable('bash-language-server')
    autocmd User lsp_setup call lsp#register_server({
                \ 'name': 'bash-language-server',
                \ 'cmd': {server_info -> ['bash-language-server', 'start']},
                \ 'allowlist': ['sh', 'bash'],
                \ })
endif

function! s:LspConfig() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=auto

    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> K <plug>(lsp-hover)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
endfunction

augroup bash_lsp
    autocmd!
    autocmd User lsp_buffer_enabled call s:LspConfig()
augroup END
highlight LspErrorVirtualText
            \ cterm=NONE ctermfg=Red ctermbg=NONE
            \ gui=NONE guifg=#ff5f5f guibg=NONE

highlight LspWarningVirtualText
            \ cterm=NONE ctermfg=Yellow ctermbg=NONE
            \ gui=NONE guifg=#d7af00 guibg=NONE

highlight LspInformationVirtualText
            \ cterm=NONE ctermfg=Yellow ctermbg=NONE
            \ gui=NONE guifg=#5fafdf guibg=NONE

highlight LspHintVirtualText
            \ cterm=NONE ctermfg=DarkGray ctermbg=NONE
            \ gui=NONE guifg=#808080 guibg=NONE
highlight lspReference
            \ cterm=NONE ctermbg=NONE
            \ gui=NONE guibg=NONE
highlight Pmenu    ctermfg=White ctermbg=DarkGray guifg=#000000 guibg=#ffffff
function! CenterLines(lines) abort
    let l:width = &columns
    let l:out = []
    for l:line in a:lines
        let l:len = strdisplaywidth(l:line)
        let l:pad = max([0, float2nr((l:width - l:len) / 2)])
        call add(l:out, repeat(' ', l:pad) . l:line)
    endfor

    return l:out
endfunction

function! FigletHeader(text) abort
    let l:cmd = 'echo;echo;echo;echo;figlet -f big ' . shellescape(a:text)
    let l:lines = systemlist(l:cmd)
    call add(l:lines, '[CTRL+F] to search files')
    call add(l:lines, '')
    return CenterLines(l:lines)
endfunction

let g:startify_custom_header = FigletHeader('Welcome to VIM')
let g:startify_enable_special = 0
let g:startify_custom_footer = []
let g:startify_files_number = 0
let g:startify_change_to_dir = 0
let g:startify_session_persistence = 0
call plug#begin()
Plug 'mhinz/vim-startify'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
call plug#end()
set fillchars=eob:\ 
highlight StartifyHeader ctermfg=White ctermbg=NONE guifg=White guibg=NONE
function! HideCursor() abort
    let s:old_t_ve = &t_ve
    let &t_ve = ''
    silent! call system("printf '\033[?251' > /dev/tty")
endfunction
function! ShowCursor() abort
    if exists('s:old_t_ve')
        let &t_ve = s:old_t_ve
    endif
    silent! call system("printf '\033[?25h' > /dev/tty")
endfunction
augroup startify_clean
    autocmd!
    autocmd FileType startify set noruler laststatus=0 noshowcmd
    autocmd FileType startify call HideCursor()
    autocmd BufLeave * call ShowCursor()
    autocmd VimLeavePre * call ShowCursor()
    autocmd VimLeave * call ShowCursor()
augroup END
nnoremap <C-f> :Files ~<CR>
let $FZF_DEFAULT_OPTS = "--preview-label=' File preview: ' --preview-label-pos=2 --border-label=' Files in directory: ' --border-label-pos=2 --bind ctrl-j:preview-down,ctrl-k:preview-up,ctrl-d:preview-page-down,ctrl-u:preview-page-up --prompt='Search in: ' --pointer='->' --marker='' --scrollbar='' --color=bg:-1,bg+:-1,fg:white,fg+:white,pointer:white,marker:white,hl:white,hl+:white"
