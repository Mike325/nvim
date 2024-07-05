" CtrlP settings
" github.com/mike325/.vim

if !has#plugin('ctrlp.vim') || exists('g:config_ctrlp')
    finish
endif

let g:config_ctrlp = 1

function! plugins#ctrlp_vim#installcmatcher(info) abort
    if a:info.status ==# 'installed' || a:info.force
        if os#name('windows')
            !./install_windows.bat
        else
            !./install.sh
        endif
    endif
endfunction

let g:ctrlp_map = '<C-p>'
" let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_cmd = 'exe "CtrlP".get(["", "MRU", "Buffer"], v:count)'

nnoremap <C-b> :CtrlPBuffer<CR>
nnoremap <C-f> :CtrlPMRUFiles<CR>
nnoremap <C-q> :CtrlPQuickfix<CR>

" if has#plugin('ctrlp-modified.vim')
"     nnoremap <C-x> :CtrlPModified<CR>
" endif

" :CtrlPRTS
" :CtrlPMixed

let g:ctrlp_extensions = ['quickfix', 'undo', 'line', 'changes', 'mixed']

let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_by_filename         = 1
let g:ctrlp_follow_symlinks     = 1
let g:ctrlp_mruf_case_sensitive = 1
let g:ctrlp_show_hidden         = 1
let g:ctrlp_max_history = &history

" CtrlP's windows settings
let g:ctrlp_match_window        = 'bottom,order:ttb,min:1,max:30,results:50'
" Search files in the current repo or in the file's dir
let g:ctrlp_working_path_mode   = 'ra'
" Opens files in the current windows, whether or not they had been opened in others windows
let g:ctrlp_switch_buffer       = 'et'

let g:ctrlp_cache_dir = os#cache() . '/ctrlp'

let g:ctrlp_max_files = (has#plugin('fruzzy')         ||
                        \ has#plugin('ctrlp-cmatcher') ||
                        \ has#plugin('ctrlp-py-matcher')) ? 0 : 1

if has#plugin('fruzzy')
    let g:ctrlp_match_func = {'match': 'fruzzy#ctrlp#matcher'}
elseif has#plugin('ctrlp-cmatcher')
    let g:ctrlp_match_func = {'match' : 'matcher#cmatch' }
elseif has#plugin('ctrlp-py-matcher')
    let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
endif

let g:ctrlp_user_command = {
    \   'types': {
    \       1: ['.git', 'cd %s && ' . tools#select_filelist(v:true) ]
    \   },
    \   'fallback': "find %s -type f -iname '*' ". tools#ignores('find') .' ',
    \ }

" Do not clear filenames cache, to improve CtrlP startup
" You can manualy clear it by <F5>
" This var is set on Vim Startup, New Session open and dir changed
if executable('rg') || executable('ag') || executable('fd')
    let g:ctrlp_clear_cache_on_exit = 1
    let g:ctrlp_user_command.fallback = tools#select_filelist(0)
elseif os#name('windows')
    " NOTE: If neovim-qt is launch fron git-bash/cywing find command will be the unix,
    "       if it's launch from a non unix enviroment then find will be the one in windows
    let s:windows_find = system('find --help')
    if v:shell_error != 0
        let g:ctrlp_user_command.fallback =  'dir %s /-n /b /s /a-d | findstr /v /c:.git /c:.svn /c:.exe /c:.pyc /c:.log'
    endif
    unlet s:windows_find
endif
