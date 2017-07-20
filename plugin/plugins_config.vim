" ############################################################################
"
"                            Plugin configurations
"
"                                     -`
"                     ...            .o+`
"                  .+++s+   .h`.    `ooo/
"                 `+++%++  .h+++   `+oooo:
"                 +++o+++ .hhs++. `+oooooo:
"                 +s%%so%.hohhoo'  'oooooo+:
"                 `+ooohs+h+sh++`/:  ++oooo+:
"                  hh+o+hoso+h+`/++++.+++++++:
"                   `+h+++h.+ `/++++++++++++++:
"                            `/+++ooooooooooooo/`
"                           ./ooosssso++osssssso+`
"                          .oossssso-````/osssss::`
"                         -osssssso.      :ssss``to.
"                        :osssssss/  Mike  osssl   +
"                       /ossssssss/   8a   +sssslb
"                     `/ossssso+/:-        -:/+ossss'.-
"                    `+sso+:-`                 `.-/+oso:
"                   `++:.  github.com/mike325/.vim  `-/+/
"                   .`                                 `/
"
" ############################################################################

" LazyLoad {{{

" Better behave buffer deletion
nnoremap <leader>d :Bdelete!<CR>

" CtrlP {{{

nnoremap <C-p> :CtrlP<CR>
nnoremap <C-b> :CtrlPBuffer<CR>
nnoremap <C-f> :CtrlPMRUFiles<CR>

let g:ctrlp_map = '<C-p>'
let g:ctrlp_cmd = 'CtrlP'

" Do not clear filenames cache, to improve CtrlP startup
" You can manualy clear it by <F5>
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_by_filename         = 0
let g:ctrlp_follow_symlinks     = 1
let g:ctrlp_mruf_case_sensitive = 1
let g:ctrlp_match_window        = 'bottom,order:ttb,min:1,max:30,results:50'
let g:ctrlp_working_path_mode   = 'ra'

let g:ctrlp_cache_dir = g:parent_dir . 'cache/ctrlp'

 if &runtimepath =~ 'ctrlp-py-matcher' && has("python")
    let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }

    " Set no file limit, we are building a big project
    let g:ctrlp_max_files = 0
    " let g:ctrlp_lazy_update         = 350
endif

if executable("ag")
    let g:ctrlp_user_command = {
        \   'types': {
        \       1: ['.git', 'cd %s && git ls-files -co --exclude-standard' . g:ignore_patterns.git ]
        \   },
        \   'fallback': 'ag %s -S -l --nocolor --nogroup --hidden '. g:ignore_patterns.ag . '-g ""',
        \ }
elseif has("win32") || has("win64")
    " Actually I don't use Windows that much, so if someone comes with
    " something better I will definitely use it
    let g:ctrlp_user_command = {
        \   'types': {
        \       1: ['.git', 'cd %s && git ls-files -co --exclude-standard' . g:ignore_patterns.git ]
        \   },
        \   'fallback': 'dir %s /-n /b /s /a-d',
        \ }
else
    let g:ctrlp_user_command = {
        \   'types': {
        \       1: ['.git', 'cd %s && git ls-files -co --exclude-standard' . g:ignore_patterns.git ]
        \   },
        \   'fallback': 'find %s -type f \( -iname "*" ' . g:ignore_patterns.find . ' \) -readable',
        \ }
endif
" NOTE: This only works if g:ctrlp_user_command is not set
" let g:ctrlp_custom_ignore = {
"             \ 'file': '\v\.(',
"             \ 'dir':  '\v[\/](',
"             \ }
"
" for [ ignore_type, ignore_list ] in items(g:ignores)
"
"     " I don't want to ignore logs from CtrlP list
"     if ignore_type == "logs"
"         continue
"     endif
"
"     for item in ignore_list
"         if ignore_type == "vcs"
"             let g:ctrlp_custom_ignore.dir  .= "\\." . item . "|"
"         elseif ignore_type == "tmp_dir"
"             " Add both versions, normal and hidden
"             let g:ctrlp_custom_ignore.dir  .= item . "|"
"             let g:ctrlp_custom_ignore.dir  .= "\\." . item . "|"
"         elseif l:ignore_type != "full_name_files"
"             let g:ctrlp_custom_ignore.file .= item . "|"
"         endif
"     endfor
"
"     let g:ctrlp_custom_ignore.file = substitute(g:ctrlp_custom_ignore.file, "\\$", "", "")
"     let g:ctrlp_custom_ignore.dir  = substitute(g:ctrlp_custom_ignore.dir, "\\$", "", "")
" endfor
"
" let g:ctrlp_custom_ignore.file = substitute(g:ctrlp_custom_ignore.file, "|$", "", "") . ')$'
" let g:ctrlp_custom_ignore.dir  = substitute(g:ctrlp_custom_ignore.dir, "|$", "", "") . ')$'

let g:ctrlp_funky_multi_buffers = 1
let g:ctrlp_funky_sort_by_mru   = 1

" }}} EndCtrlP

" NERDTree {{{

" Ignore files in NERDTree
let g:NERDTreeIgnore              = ['\.pyc$', '\~$', '\.sw$', '\.swp$']
let g:NERDTreeShowBookmarks       = 1
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ "Unknown"   : "?"
    \ }

" If you don't have unicode, uncomment the following lines
" let NERDTreeDirArrowExpandable  = '+'
" let NERDTreeDirArrowCollapsible = '~'

nnoremap T :NERDTreeToggle<CR>
nnoremap <F3> :NERDTreeToggle<CR>
inoremap <F3> <Esc><F3>
vnoremap <F3> <Esc><F3>

" Enable line numbers
let g:NERDTreeShowLineNumbers=1
" Make sure relative line numbers are used
augroup NERDNumbers
    autocmd!
    autocmd FileType nerdtree setlocal relativenumber
augroup end

" }}} EndNERDTree

" }}} EndLazyLoad


" Vim-expand-region {{{

" TODO improve expanding regions for common file types
if &runtimepath =~ "vim-expand-region"
    let g:expand_region_text_objects = {
        \ 'iw'  :0,
        \ 'iW'  :0,
        \ 'i"'  :0,
        \ 'i''' :0,
        \ 'i]'  :1,
        \ 'i)'  :1,
        \ 'il'  :0,
        \ 'ii'  :1,
        \ 'ip'  :0,
        \ 'i}'  :1,
        \ 'ie'  :0,
    \ }
endif

" }}} EndVim-expand-region

" EasyMotions {{{

if &runtimepath =~ 'vim-easymotion'
    " Disable default mappings
    let g:EasyMotion_do_mapping = 0
    " Turn on ignore case
    let g:EasyMotion_smartcase = 1

    " z{char} to move to {char}
    " search a character in the current buffer
    nmap \ <Plug>(easymotion-bd-f)
    vmap \ <Plug>(easymotion-bd-f)
    " search a character in the current layout
    nmap <leader>\ <Plug>(easymotion-overwin-f)
    vmap <leader>\ <Plug>(easymotion-overwin-f)

    " repeat the last motion
    nmap <leader>. <Plug>(easymotion-repeat)
    vmap <leader>. <Plug>(easymotion-repeat)
    " repeat the next match of the current last motion
    nmap <leader>, <Plug>(easymotion-next)
    vmap <leader>, <Plug>(easymotion-next)
    " repeat the prev match of the current last motion
    nmap <leader>; <Plug>(easymotion-prev)
    vmap <leader>; <Plug>(easymotion-prev)
endif

" }}} EndEasyMotions

" Sessions {{{

if &runtimepath =~ 'vim-session'
    " Session management
    " Auto save on exit
    let g:session_autosave = 'no'
    " Don't ask for load last session
    let g:session_autoload = 'no'

    let g:session_directory = g:base_path.'sessions'

    " Quick open session
    nnoremap <leader>o :OpenSession
    " Save current files in a session
    nnoremap <leader>s :SaveSession
    " Save the current session before close it, useful for neovim terminals
    nnoremap <leader><leader>c :SaveSession<CR>:CloseSession!<CR>
    " Quick save current session
    nnoremap <leader><leader>s :SaveSession<CR>
    " Quick delete session
    nnoremap <leader><leader>d :DeleteSession<CR>
endif

" }}} EndSessions

" Grepper {{{

if &runtimepath =~ 'vim-grepper'

    let g:grepper       = {}    " initialize g:grepper with empty dictionary
    let g:grepper.jump  = 0
    let g:grepper.open  = 1
    let g:grepper.tools = ['git', 'ag', 'ack', 'grep', 'findstr']
    let g:grepper.dir   = 'repo,cwd'

    " let g:grepper.highlight = 1
    " let g:grepper.rg.grepprg .= ' --smart-case'

    " I like to keep Ag and grep as a ignore case searchers (smart case for Ag)
    " and git as a case sensitive project searcher
    let g:grepper.ag = {
        \ 'grepprg':    'ag -S -U --hidden --ignore .ropeproject --ignore .git --ignore .svn --ignore .hg --vimgrep',
        \ 'grepformat': '%f:%l:%c:%m,%f:%l:%m',
        \ 'escape':     '\^$.*+?()[]{}|',
        \ }

    let g:grepper.grep = {
        \ 'grepprg':    'grep --exclude-dir .svn --exclude-dir .git --exclude-dir .ropeproject -RIni $*',
        \ 'grepprgbuf': 'grep -HIn -- $* $.',
        \ 'grepformat': '%f:%l:%m',
        \ 'escape':     '\^$.*[]',
        \ }

    let g:grepper.git = {
        \ 'grepprg':    'git grep -nI',
        \ 'grepformat': '%f:%l:%m',
        \ 'escape':     '\^$.*[]',
        \ }

    let g:grepper.findstr = {
        \ 'grepprg': 'findstr -rspnc:$* *',
        \ 'grepprgbuf': 'findstr -rpnc:$* $.',
        \ 'grepformat': '%f:%l:%m',
        \ 'wordanchors': ['\<', '\>'],
        \ }

    " You can use <TAB> to change the current grep tool
    nnoremap <C-g> :Grepper<CR>

    command! Todo :Grepper -query '\(TODO\|FIXME\)'

    " Motions for grepper command
    nmap gs  <plug>(GrepperOperator)
    xmap gs  <plug>(GrepperOperator)
endif

" }}} EndGrepper

" NerdCommenter {{{

if &runtimepath =~ 'nerdcommenter'
    let g:NERDCompactSexyComs        = 0      " Use compact syntax for prettified multi-line comments
    let g:NERDSpaceDelims            = 1      " Add spaces after comment delimiters by default
    let g:NERDTrimTrailingWhitespace = 1      " Enable trimming of trailing whitespace when uncommenting
    let g:NERDCommentEmptyLines      = 1      " Allow commenting and inverting empty lines
                                              " (useful when commenting a region)
    let g:NERDDefaultAlign           = 'left' " Align line-wise comment delimiters flush left instead
                                              " of following code indentation
    let g:NERDCustomDelimiters = {
        \ 'python': { 'left': '#', 'leftAlt': '"""', 'rightAlt': '"""' },
        \ 'c': { 'left': '//', 'leftAlt': '/**', 'rightAlt': '*/' },
        \ 'cpp': { 'left': '//', 'leftAlt': '/**', 'rightAlt': '*/' }
        \ }
endif

" }}} EndNerdCommenter

" Themes {{{

if &runtimepath =~ 'gruvbox'
    try
        colorscheme gruvbox
    catch
        echo 'Please run :PlugInstall to complete the installation or remove "colorscheme gruvbox"'
    endtry

    let g:gruvbox_contrast_dark = 'hard'
    nnoremap csg :colorscheme gruvbox<CR>:AirlineTheme gruvbox<CR>
endif

if &runtimepath =~ 'vim-monokai'
    nnoremap csm :colorscheme monokai<CR>:AirlineTheme molokai<CR>
endif

if &runtimepath =~ 'jellybeans.vim'
    nnoremap csj :colorscheme jellybeans<CR>:AirlineTheme solarized<CR>
endif

if &runtimepath =~ 'onedark'
    nnoremap cso :colorscheme onedark<CR>:AirlineTheme solarized<CR>
endif

if &runtimepath =~ 'vim-gotham'
    " b for batman
    nnoremap csb :colorscheme gotham<CR>:AirlineTheme gotham<CR>
endif

" }}} EndThemes

" Airline {{{

if &runtimepath =~ 'vim-airline'
    let g:airline#extensions#tabline#enabled           = 1
    let g:airline#extensions#tabline#fnamemod          = ':t'
    let g:airline#extensions#tabline#close_symbol      = '×'
    let g:airline#extensions#tabline#show_tabs         = 1
    let g:airline#extensions#tabline#show_buffers      = 1
    let g:airline#extensions#tabline#show_close_button = 0
    let g:airline#extensions#tabline#show_splits       = 0

    " Powerline fonts, check https://github.com/powerline/fonts.git for more
    " info
    " unicode symbols
    " let g:airline#extensions#branch#symbol = '⎇ '
    " let g:airline#extensions#whitespace#symbol = 'Ξ'
    " let g:airline_left_sep = '▶'
    " let g:airline_right_sep = '◀'
    " let g:airline_linecolumn_prefix = '␊ '
    " let g:airline_paste_symbol = 'ρ'
    let g:airline_powerline_fonts = 1
endif

if &runtimepath =~ 'vim-airline-themes'
    " let g:airline_theme = 'molokai'
    " let g:airline_theme = 'solarized'
    let g:airline_theme = 'gruvbox'
endif

" }}} EndAirline

" Snippets and completion {{{

" DelimitMate {{{

if &runtimepath =~ "delimitMate"
    " let delimitMate_matchpairs = "(:),[:],{:},<:>"
    " au FileType vim,html let b:delimitMate_matchpairs = "(:),[:],{:},<:>"

    " let delimitMate_expand_space = 1
    " au FileType tcl let b:delimitMate_expand_space = 1

    function! HandleEmptyPairs()
        if pumvisible()
            return "\<C-y>"
        endif
        return delimitMate#ExpandReturn()
    endfunction
endif

" }}} EndDelimitMate

" SnipMate {{{

" TODO make SnipMate mappings behave as UltiSnips ones
if &runtimepath =~ 'vim-snipmate'
    " nnoremap <C-k> <Plug>snipMateNextOrTrigger
    " inoremap <C-k> <Plug>snipMateNextOrTrigger
endif

" }}} EndSnipMate

" UltiSnips {{{

if &runtimepath =~ 'ultisnips'
    let g:UltiSnipsSnippetDirectories=["UltiSnips"]

    if has('python3')
        let g:UltiSnipsUsePythonVersion = 3
    endif

    let g:ulti_expand_or_jump_res = 0
    let g:ulti_jump_backwards_res = 0
    let g:ulti_jump_forwards_res = 0
    let g:ulti_expand_res = 0

    function! <SID>ExpandSnippetOrComplete()
        call UltiSnips#ExpandSnippet()
        if g:ulti_expand_res == 0
            if pumvisible()
                return "\<C-n>"
            else
                call UltiSnips#JumpForwards()
                if g:ulti_jump_forwards_res == 0
                    return "\<TAB>"
                endif
            endif
        endif
        return ""
    endfunction

    function! NextSnippetOrReturn()
        call UltiSnips#ExpandSnippet()
        if g:ulti_expand_res == 0
            if pumvisible()
                return "\<C-y>"
            else
                if &runtimepath =~ "delimitMate" && delimitMate#WithinEmptyPair()
                    return delimitMate#ExpandReturn()
                else
                    call UltiSnips#JumpForwards()
                    if g:ulti_jump_forwards_res == 0
                        return "\<CR>"
                    endif
                endif
            endif
        endif
        return ""
    endfunction

    function! NextSnippetOrNothing()
        call UltiSnips#JumpForwards()
        return g:ulti_jump_forwards_res
    endfunction

    function! PrevSnippetOrNothing()
        if pumvisible()
            return "\<C-p>"
        else
            call UltiSnips#JumpBackwards()
            return ""
        endif
    endfunction

    let g:UltiSnipsExpandTrigger       = "<C-l>"

    " inoremap <silent><TAB>   <C-R>=<SID>ExpandSnippetOrComplete()<CR>
    " inoremap <silent><S-TAB> <C-R>=PrevSnippetOrNothing()<CR>
    inoremap <expr><TAB>     pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr><S-TAB>   pumvisible() ? "\<C-p>" : ""
    inoremap <silent><CR>    <C-R>=NextSnippetOrReturn()<CR>

else
    inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""

    if &runtimepath =~ "delimitMate"
        inoremap <silent><CR>  <C-R>=HandleEmptyPairs()<CR>
    else
        inoremap <expr><CR> pumvisible() ? "\<C-y>" : "\<CR>"
    endif

endif

" }}} EndUltiSnips

" JavaComplete {{{

if &runtimepath =~ 'vim-javacomplete2'
    nnoremap <leader>si <Plug>(JavaComplete-Imports-AddSmart)
    nnoremap <leader>mi <Plug>(JavaComplete-Imports-AddMissing)
endif

" }}} EndJavaComplete

" Vimtext {{{
if &runtimepath =~ "vimtext"
    " let g:vimtex_enabled = 1
    let g:vimtex_fold_enabled = 1
    let g:vimtex_imaps_leader = '`'
    let g:vimtex_mappings_enabled = 1
    let g:vimtex_motion_enabled = 1
    let g:vimtex_text_obj_enabled = 1
    let g:tex_flavor = 'latex'
endif
" EndVimtext }}}

" Jedi {{{

if  &runtimepath =~ 'jedi-vim'
    let g:jedi#popup_select_first       = 0
    let g:jedi#popup_on_dot             = 0
    let g:jedi#completions_command      = "<C-c>"
    let g:jedi#documentation_command    = "K"
    let g:jedi#usages_command           = "<leader>u"
endif

" }}} EndJedi

" Python-mode {{{

if  &runtimepath =~ 'python-mode'
    let g:pymode_rope                 = 0
    let g:pymode_rope_lookup_project  = 0
    let g:pymode_rope_complete_on_dot = 0
    let g:pymode_lint_on_write        = 0
    let g:pymode_lint_checkers        = ['flake8', 'pep8', 'mccabe']
    let g:ropevim_autoimport_modules  = [
        \   "os.*",
        \   "sys.*",
        \   "traceback",
        \   "django.*",
        \   "xml.etree",
        \ ]
endif

" }}} EndJedi

" SuperTab {{{
if &runtimepath =~ 'supertab'
    let g:SuperTabDefaultCompletionType = "context"
    let g:SuperTabContextDefaultCompletionType = "<c-p>"
    let g:SuperTabCompletionContexts = ['s:ContextText', 's:extDiscover']
    let g:SuperTabContextDiscoverDiscovery = ["&omnifunc:<c-x><c-o>"]
    autocmd FileType *
            \if &omnifunc != '' |
            \   call SuperTabChain(&omnifunc, "<c-p>") |
            \   call SuperTabSetDefaultCompletionType("<c-x><c-o>") |
            \endif
endif
" }}} EndSuperTab

" SimpleAutoComplPop {{{
" TODO Plugin Temporally disable, is currently unmaintained
" TODO path completion should be improve
if &runtimepath =~ 'SimpleAutoComplPop'
    autocmd FileType * call sacp#enableForThisBuffer({ "matches": [
        \ { '=~': '\v[a-zA-Z]{2}$' , 'feedkeys': "\<C-x>\<C-p>" , "ignoreCompletionMode":1} ,
        \ { '=~': '/$'             , 'feedkeys': "\<C-x>\<C-f>" , "ignoreCompletionMode":1} ,
    \ ]})

    autocmd FileType python call sacp#enableForThisBuffer({ "matches": [
        \ { '=~': '\v[a-zA-Z]{2}$' , 'feedkeys': "\<C-x>\<C-p>"                           , "ignoreCompletionMode":1} ,
        \ { '=~': '\.$'            , 'feedkeys': "\<Plug>(sacp_cache_fuzzy_omnicomplete)" , "ignoreCompletionMode":1} ,
        \ { '=~': '/$'             , 'feedkeys': "\<C-x>\<C-f>"                           , "ignoreCompletionMode":1} ,
    \ ]})

    autocmd FileType javascript,java,go call sacp#enableForThisBuffer({ "matches": [
        \ { '=~': '\v[a-zA-Z]{2}$' , 'feedkeys': "\<C-x>\<C-p>"                           , "ignoreCompletionMode":1} ,
        \ { '=~': '\.$'            , 'feedkeys': "\<Plug>(sacp_cache_fuzzy_omnicomplete)" , "ignoreCompletionMode":1} ,
        \ { '=~': '/$'             , 'feedkeys': "\<C-x>\<C-f>"                           , "ignoreCompletionMode":1} ,
    \ ]})

    autocmd BufNewFile,BufRead,BufEnter *.cpp,*.hpp,*.c,*.h call sacp#enableForThisBuffer({ "matches": [
        \ { '=~': '\v[a-zA-Z]{2}$' , 'feedkeys': "\<C-x>\<C-p>"                             , "ignoreCompletionMode":1} ,
        \ { '=~': '\.$'            , 'feedkeys': "\<Plug>(sacp_cache_fuzzy_omnicomplete)"   , "ignoreCompletionMode":1} ,
        \ { '=~': '->$'            , 'feedkeys': "\<Plug>(sacp_cache_fuzzy_omnicomplete)"   , "ignoreCompletionMode":1} ,
        \ { '=~': '::$'            , 'feedkeys': "\<Plug>(sacp_cache_fuzzy_omnicomplete)"   , "ignoreCompletionMode":1} ,
        \ { '=~': '/$'             , 'feedkeys': "\<C-x>\<C-f>" , "ignoreCompletionMode":1} ,
    \ ]})
endif

" }}} SimpleAutoComplPop

" Neocomplcache {{{

if &runtimepath =~ 'neocomplcache.vim'
    " Use neocomplcache.
    let g:neocomplcache_enable_at_startup = 1

    " Use smartcase.
    let g:neocomplcache_enable_smart_case = 1

    " Set minimum syntax keyword length.
    let g:neocomplcache_fuzzy_completion_start_length = 1
    let g:neocomplcache_enable_fuzzy_completion       = 1
    let g:neocomplcache_enable_camel_case_completion  = 1
    let g:neocomplcache_min_syntax_length             = 1
    let g:neocomplcache_auto_completion_start_length  = 1
    let g:neocomplcache_lock_buffer_name_pattern      = '\*ku\*'

    let g:neocomplcache_omni_patterns = get(g:,'neocomplcache_omni_patterns',{})

    " inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
    " inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
    " inoremap <expr><C-y>  neocomplcache#smart_close_popup()
    " inoremap <expr><C-e>  neocomplcache#cancel_popup()

    let g:neocomplcache_omni_patterns.python = '[^.[:digit:] *\t]\%(\.\)'
    let g:neocomplcache_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
    let g:neocomplcache_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

    let g:neocomplcache_filename_include_exts = get(g:,'neocomplcache_filename_include_exts',{})
    let g:neocomplcache_filename_include_exts.cpp = ['', 'h', 'hpp', 'hxx']
    let g:neocomplcache_filename_include_exts.c = ['', 'h']

    let g:neocomplcache_delimiter_patterns = get(g:,'neocomplcache_delimiter_patterns',{})
    let g:neocomplcache_delimiter_patterns.vim = ['#']
    let g:neocomplcache_delimiter_patterns.cpp = ['::']

    let g:neocomplcache_sources_list   = get(g:,'neocomplcache_delimiter_patterns',{})
    let g:neocomplcache_sources_list._ = ['omni_complete', 'syntax_complete', 'member_complete', 'filename_complete', 'tags_complete', 'buffer_complete']

    let g:neocomplcache_sources_list.c = ['omni_complete', 'syntax_complete', 'member_complete', 'filename_complete', 'tags_complete', 'buffer_complete']
    let g:neocomplcache_sources_list.cpp = ['omni_complete', 'syntax_complete', 'member_complete', 'filename_complete', 'tags_complete', 'buffer_complete']
    let g:neocomplcache_sources_list.java = ['omni_complete', 'syntax_complete', 'member_complete', 'filename_complete', 'tags_complete', 'buffer_complete']
    let g:neocomplcache_sources_list.python = ['omni_complete', 'syntax_complete', 'member_complete', 'filename_complete', 'tags_complete', 'buffer_complete']

    " Syntax seems to cause some problems in old Vim's versions ( <= 703 )
    if has("nvim") || (v:version >= 704)
        autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
    endif
endif

" }}} EndNeocomplcache

" Neocomplete {{{

if &runtimepath =~ 'neocomplete.vim'
    let g:neocomplete#enable_at_startup = 1

    " Use smartcase.
    let g:neocomplete#enable_smart_case = 1
    let g:neocomplete#enable_refresh_always = 1

    " Set minimum syntax keyword length.
    let g:neocomplete#sources#syntax#min_keyword_length = 1
    let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

    if !exists('g:neocomplete#keyword_patterns')
        let g:neocomplete#keyword_patterns = {}
    endif

    " inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    " inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    " inoremap <expr><C-y>  neocomplete#mappings#smart_close_popup()
    " inoremap <expr><C-e>  neocomplete#cancel_popup()

    let g:neocomplete#omni#input_patterns = get(g:,'neocomplete#omni#input_patterns',{})

    let g:neocomplete#sources={}
    let g:neocomplete#sources._    = ['buffer', 'member', 'file', 'ultisnips']

    let g:neocomplete#sources.vim        = ['buffer', 'member', 'file', 'ultisnips']
    let g:neocomplete#sources.c          = ['buffer', 'member', 'file', 'omni', 'ultisnips']
    let g:neocomplete#sources.cpp        = ['buffer', 'member', 'file', 'omni', 'ultisnips']
    let g:neocomplete#sources.go         = ['buffer', 'member', 'file', 'omni', 'ultisnips']
    let g:neocomplete#sources.java       = ['buffer', 'member', 'file', 'omni', 'ultisnips']
    let g:neocomplete#sources.python     = ['buffer', 'member', 'file', 'omni', 'ultisnips']
    let g:neocomplete#sources.javascript = ['buffer', 'member', 'file', 'omni', 'ultisnips']
    let g:neocomplete#sources.ruby       = ['buffer', 'member', 'file', 'ultisnips']

    " if !exists('g:neocomplete#sources#omni#input_patterns')
    "     let g:neocomplete#sources#omni#input_patterns = {}
    " endif

    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
endif

" }}} EndNeocomplete

" Deoplete {{{

if &runtimepath =~ 'deoplete.nvim'
    let g:deoplete#enable_at_startup = 1

    " Use smartcase.
    let g:deoplete#enable_smart_case = 1
    let g:deoplete#enable_refresh_always = 1

    " Set minimum syntax keyword length.
    let g:deoplete#sources#syntax#min_keyword_length = 1
    let g:deoplete#lock_buffer_name_pattern = '\*ku\*'

    " inoremap <expr><BS> deoplete#mappings#smart_close_popup()."\<C-h>"
    " inoremap <expr><C-h> deoplete#mappings#smart_close_popup()."\<C-h>"
    " inoremap <expr><C-y>  deoplete#mappings#smart_close_popup()
    " inoremap <expr><C-e>  deoplete#cancel_popup()

    let g:deoplete#omni#input_patterns = get(g:,'deoplete#omni#input_patterns',{})

    let g:deoplete#omni#input_patterns.java = ['[^. \t0-9]\.\w*']
    let g:deoplete#omni#input_patterns.javascript = ['[^. \t0-9]\.\w*']
    let g:deoplete#omni#input_patterns.python = ['[^. \t0-9]\.\w*']
    let g:deoplete#omni#input_patterns.go = ['[^. \t0-9]\.\w*']
    let g:deoplete#omni#input_patterns.ruby = ['[^. *\t]\.\w*', '[a-zA-Z_]\w*::']

    let g:deoplete#omni#input_patterns.c = [
                \'[^. \t0-9]\.\w*',
                \'[^. \t0-9]\->\w*',
                \'[^. \t0-9]\::\w*',
                \]

    let g:deoplete#omni#input_patterns.cpp = [
                \'[^. \t0-9]\.\w*',
                \'[^. \t0-9]\->\w*',
                \'[^. \t0-9]\::\w*',
                \]

    " let g:deoplete#sources._ = ['buffer', 'member', 'file', 'tags', 'ultisnips']
    let g:deoplete#sources={}
    let g:deoplete#sources._    = ['buffer', 'member', 'file', 'tags', 'ultisnips']

    let g:deoplete#sources.vim        = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
    let g:deoplete#sources.c          = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
    let g:deoplete#sources.cpp        = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
    let g:deoplete#sources.go         = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
    let g:deoplete#sources.java       = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
    let g:deoplete#sources.python     = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
    let g:deoplete#sources.javascript = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
    let g:deoplete#sources.ruby       = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']

    " if !exists('g:deoplete#omni#input_patterns')
    "     let g:deoplete#omni#input_patterns = {}
    " endif

    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
    call deoplete#custom#set('ultisnips', 'matchers', ['matcher_full_fuzzy'])
endif

if &runtimepath =~ 'deoplete-jedi'
    let g:deoplete#sources#jedi#enable_cache   = 1
    let g:deoplete#sources#jedi#show_docstring = 1
endif

if &runtimepath =~ 'deoplete-clang'
    " Set posible locations in linux
    " /usr/lib/libclang.so
    " /usr/lib/clang
    let g:deoplete#sources#clang#libclang_path = '/usr/lib/libclang.so'
    let g:deoplete#sources#clang#clang_header  = '/usr/lib/clang'
endif

if &runtimepath =~ 'deoplete-go'
    let g:deoplete#sources#go             = 'vim-go'
    let g:deoplete#sources#go#sort_class  = ['package', 'func', 'type', 'var', 'const']
    let g:deoplete#sources#go#use_cache   = 1
    let g:deoplete#sources#go#package_dot = 1
endif

" }}} EndDeoplete


" YouCompleteMe {{{

if &runtimepath =~ 'YouCompleteMe'
    let g:ycm_complete_in_comments                      = 1
    let g:ycm_seed_identifiers_with_syntax              = 1
    let g:ycm_add_preview_to_completeopt                = 1
    let g:ycm_autoclose_preview_window_after_completion = 1
    let g:ycm_autoclose_preview_window_after_insertion  = 1
    let g:ycm_key_detailed_diagnostics                  = '<leader>D'

    if executable("ctags")
        let g:ycm_collect_identifiers_from_tags_files = 1
    endif

    nnoremap <F5> :YcmForceCompileAndDiagnostics<CR>
    inoremap <F5> :YcmForceCompileAndDiagnostics<CR>

    nnoremap <leader>F :YcmCompleter FixIt<CR>
    nnoremap <leader>gr :YcmCompleter GoToReferences<CR>
    nnoremap <leader>gg :YcmCompleter GoTo<CR>
    nnoremap <leader>gp :YcmCompleter GetParent<CR>
    nnoremap <leader>gi :YcmCompleter GoToInclude<CR>
    nnoremap <leader>gt :YcmCompleter GetType<CR>

    let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
    let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']

    " In case there are other completion plugins
    " let g:ycm_filetype_blacklist = {
    "       \ 'tagbar' : 1,
    "       \}
    "
    " In case there are other completion plugins
    " let g:ycm_filetype_specific_completion_to_disable = {
    "       \ 'gitcommit': 1
    "       \}
endif

" }}} EndYouCompleteMe


" Completor {{{

if &runtimepath =~ 'completor.vim'
    let g:completor_min_chars = 1

    let g:completor_java_omni_trigger = '([\w-]+|@[\w-]*|[\w-]+.[\w-]+)$'
    let g:completor_css_omni_trigger = '([\w-]+|@[\w-]*|[\w-]+:\s*[\w-]*)$'
endif

" }}} EndCompletor

" }}} End Snippets and completion

" Syntax check {{{

" Neomake {{{
if &runtimepath =~ "neomake"
    nnoremap <F6> :Neomake<CR>
    nnoremap <F7> :lopen<CR>
    nnoremap <F8> :lclose<CR>

    " TODO Config the proper makers for the languages I use
    " JSON linter       : npm install -g jsonlint
    " Typescript linter : npm install -g typescript
    " SCSS linter       : gem install scss-lint
    " Markdown linter   : gem install mdl
    " Shell linter      : ( apt-get install / yaourt -S / dnf install ) shellcheck
    " VimL linter       : pip install vim-vint enum34==1.0.4
    " Python linter     : pip install flake8 pep8
    " C/C++ linter      : ( apt-get install / yaourt -S / dnf install ) clang gcc g++
    " Go linter         : ( apt-get install / yaourt -S / dnf install ) golang
    augroup Checkers
        autocmd!
        autocmd BufWritePost * Neomake
    augroup end

    let g:neomake_warning_sign = {
        \ 'text': 'W',
        \ 'texthl': 'WarningMsg',
        \ }

    let g:neomake_error_sign = {
        \ 'text': 'E',
        \ 'texthl': 'ErrorMsg',
        \ }

    if executable("vint")
        let g:neomake_vim_enabled_makers = ['vint']

        " The configuration scrips use Neovim commands
        let g:neomake_vim_vint_maker = {
            \ 'args': [
            \   '--enable-neovim',
            \   '-e'
            \],}
    endif

    let g:neomake_python_enabled_makers = ['flake8', 'pep8']
    let g:neomake_cpp_enabled_makers = ['clang', 'gcc']
    let g:neomake_c_enabled_makers = ['clang', 'gcc']

    " E501 is line length of 80 characters
    let g:neomake_python_flake8_maker = {
        \   'args': [
        \       '--ignore=E501'
        \],}

    let g:neomake_python_pep8_maker = {
        \ 'args': [
        \   '--max-line-length=100',
        \   '--ignore=E501'
        \],}

    let g:neomake_c_gcc_maker = {
        \   'exe': 'gcc',
        \   'args': [
        \       '-Wall',
        \       '-Wextra',
        \       '-fsyntax-only'
        \],}

    let g:neomake_cpp_gcc_maker = {
        \   'exe': 'g++',
        \   'args': [
        \      '-Wall',
        \      '-Wextra',
        \      '-Weverything',
        \      '-Wno-sign-conversion',
        \      '-fsyntax-only'
        \],}

    let g:neomake_c_clang_maker = {
        \   'exe': 'clang',
        \   'args': [
        \       '-Wall',
        \       '-Wextra',
        \       '-Weverything',
        \],}

    let g:neomake_cpp_clang_maker = {
        \   'exe': 'clang++',
        \   'args': [
        \      '-Wall',
        \      '-Wextra',
        \      '-Weverything',
        \      '-Wno-sign-conversion'
        \],}
endif

" }}} EndNeomake

" Syntastic {{{

if &runtimepath =~ "syntastic"
    " set sessionoptions-=blank
    " Set passive mode by default, can be changed with tsc map
    let g:syntastic_mode_map = {
        \ "mode": "passive",
        \ "active_filetypes": ["python", "sh"],
        \ "passive_filetypes": ["puppet"]
        \ }

    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*

    nnoremap tsc :SyntasticToggleMode<CR>

    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 0
    let g:syntastic_check_on_wq = 0

    let g:syntastic_python_checkers = ['flake8']

    " Check Syntax in the current file
    imap <F5> <ESC>:SyntasticCheck<CR>a
    nnoremap <F5> :SyntasticCheck<CR>

    " Give information about current checkers
    imap <F6> <ESC>:SyntasticInfo<CR>a
    nnoremap <F6> :SyntasticInfo<CR>

    " Show the list of errors
    imap <F7> <ESC>:Errors<CR>a
    nnoremap <F7> :Errors<CR>

    " Hide the list of errors
    imap <F8> <ESC>:lclose<CR>a
    nnoremap <F8> :lclose<CR>
endif

" }}} EndSyntastic

" }}} End Syntax check

" Tabularize {{{

if &runtimepath =~ 'tabular'
    nnoremap <leader>t= :Tabularize /=<CR>
    vmap <leader>t= :Tabularize /=<CR>

    nnoremap <leader>t: :Tabularize /:<CR>
    vmap <leader>t: :Tabularize /:<CR>

    nnoremap <leader>t" :Tabularize /"<CR>
    vmap <leader>t" :Tabularize /"<CR>

    nnoremap <leader>t# :Tabularize /#<CR>
    vmap <leader>t# :Tabularize /#<CR>

    nnoremap <leader>t* :Tabularize /*<CR>
    vmap <leader>t* :Tabularize /*<CR>
endif

" }}} EndTabularize

" Git integrations {{{

" Fugitive {{{

if &runtimepath =~ 'vim-fugitive'
    nnoremap <leader>gs :Gstatus<CR>
    nnoremap <leader>gc :Gcommit<CR>
    nnoremap <leader>gd :Gdiff<CR>
    nnoremap <leader>gw :Gwrite<CR>
    nnoremap <leader>gr :Gread<CR>
endif

" }}} EndFugitive

" Gitv {{{

if &runtimepath =~ 'gitv'
    nnoremap <leader>gv :Gitv<CR>
endif

" }}} EndGitv

" GitGutter {{{

if &runtimepath =~ 'vim-gitgutter'
    nnoremap tg :GitGutterToggle<CR>
    nnoremap tl :GitGutterLineHighlightsToggle<CR>
    let g:gitgutter_map_keys = 0

    nmap [h <Plug>GitGutterPrevHunk
    nmap ]h <Plug>GitGutterNextHunk

    nmap <leader>ghs <Plug>GitGutterStageHunk
    nmap <leader>ghu <Plug>GitGutterUndoHunk

    omap ih <Plug>GitGutterTextObjectInnerPending
    omap ah <Plug>GitGutterTextObjectOuterPending
    xmap ih <Plug>GitGutterTextObjectInnerVisual
    xmap ah <Plug>GitGutterTextObjectOuterVisual
endif

" }}} EndGitGutter

" Signature {{{

if &runtimepath =~ 'vim-signature'
    nnoremap <leader><leader>g :SignatureListGlobalMarks<CR>
    imap <C-s>g <ESC>:SignatureListGlobalMarks<CR>

    nnoremap <leader><leader>b :SignatureListBufferMarks<CR>
    imap <C-s>b <ESC>:SignatureListBufferMarks<CR>

    nnoremap tS :SignatureToggleSigns<CR>
endif

" }}} EndSignature

" }}} End Git integrations

" TagsBar {{{

if &runtimepath =~ 'tagbar'
    nnoremap tt :TagbarToggle<CR>
    nnoremap <F1> :TagbarToggle<CR>
    imap <F1> :TagbarToggle<CR>
    vmap <F1> :TagbarToggle<CR>gv
endif

" }}} EndTagsBar

" Move {{{
if &runtimepath =~ 'vim-move'
    " Manual map the functions to overlap any posible confilct
    " let g:move_key_modifier = 'C'
    let g:move_map_keys = 0

    " Set Ctrl key as default. Commands <C-j> and <C-k> to move stuf
    vmap <C-j> <Plug>MoveBlockDown
    vmap <C-k> <Plug>MoveBlockUp

    nmap <C-j> <Plug>MoveLineDown
    nmap <C-k> <Plug>MoveLineUp
    " nmap <>     <Plug>MoveBlockHalfPageDown
endif
" }}} EndMove

" IndentLine {{{

if &runtimepath =~ 'indentLine'
    " Show indentation lines for space indented code
    " If you use code tab indention you can set this
    " set list lcs=tab:\┊\

    nnoremap tdi :IndentLinesToggle<CR>
    let g:indentLine_char            = '┊'
    let g:indentLine_color_gui       = '#DDC188'
    let g:indentLine_color_term      = 214
    let g:indentLine_enabled         = 1
    let g:indentLine_setColors       = 1
    let g:indentLine_fileTypeExclude = [
        \   'text',
        \   'conf',
        \   'markdown',
        \   'git',
        \   'help',
        \ ]
    " TODO Check how to remove lines in neovim's terminal
    let g:indentLine_bufNameExclude = [
        \   '*.org',
        \   '*.log',
        \   'COMMIT_EDITMSG',
        \   'NERD_tree.*',
        \ ]
endif

" }}} EndIndentLine

" AutoFormat {{{

if &runtimepath =~ 'vim-autoformat'

    function! CheckAutoFormat()
        let b:auto_format = get(b:,'auto_format',1)

        if b:auto_format == 1
           exec "Autoformat"
        endif
    endfunction

    noremap <F9> :Autoformat<CR>

    let g:formatter_yapf_style = 'pep8'
    let g:formatters_python = ['yapf']

    augroup AutoFormat
        autocmd!
        autocmd FileType vim,python let b:autoformat_autoindent=0
        autocmd FileType css        autocmd BufWritePre silent! call CheckAutoFormat()
        autocmd FileType html       autocmd BufWritePre silent! call CheckAutoFormat()
        autocmd FileType markdown   autocmd BufWritePre silent! call CheckAutoFormat()
        autocmd FileType javascript autocmd BufWritePre silent! call CheckAutoFormat()
        autocmd FileType xml        autocmd BufWritePre silent! call CheckAutoFormat()
        autocmd FileType python     autocmd BufWritePre silent! call CheckAutoFormat()
        autocmd FileType go         autocmd BufWritePre silent! call CheckAutoFormat()
        autocmd FileType cs         autocmd BufWritePre silent! call CheckAutoFormat()
        autocmd FileType php        autocmd BufWritePre silent! call CheckAutoFormat()
        autocmd FileType sh         autocmd BufWritePre silent! call CheckAutoFormat()
        autocmd FileType vim        autocmd BufWritePre silent! call CheckAutoFormat()
        autocmd FileType java       autocmd BufWritePre silent! call CheckAutoFormat()
        autocmd FileType cpp        autocmd BufWritePre silent! call CheckAutoFormat()
        autocmd FileType c          autocmd BufWritePre silent! call CheckAutoFormat()
    augroup end
endif

" }}} EndAutoFormat

