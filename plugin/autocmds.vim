scriptencoding "uft-8"
" HEADER {{{
"
"                            Autocmds settings
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
" }}} END HEADER

" We just want to source this file once and if we have autocmd available
if !has('autocmd') || ( exists('g:autocmds_loaded') && g:autocmds_loaded )
    finish
endif

let g:autocmds_loaded = 1

" Allow to use Vim as Pager
augroup Modifiable
    autocmd!
    autocmd BufReadPre * if &modifiable == 1 | setlocal fileencoding=utf-8 | endif
augroup end

if has('nvim') || v:version > 702
    " TODO make a function to save the state of the toggles
    augroup Numbers
        autocmd!
        autocmd WinEnter    *    setlocal relativenumber number
        autocmd WinLeave    *    setlocal norelativenumber number
        autocmd InsertLeave *    setlocal relativenumber number
        autocmd InsertEnter *    setlocal norelativenumber number
    augroup end
endif

" We don't need Vim's temp files here
augroup DisableTemps
    autocmd!
    autocmd BufNewFile,BufReadPre,BufEnter /tmp/* setlocal noswapfile nobackup noundofile
augroup end


if has('nvim')
    " Set modifiable to use easymotions
    " autocmd TermOpen * setlocal modifiable

    " I like to see the numbers in the terminal
    augroup TerminalAutocmds
        autocmd!
        autocmd TermOpen * setlocal relativenumber number nocursorline
        autocmd TermOpen * setlocal noswapfile nobackup noundofile
    augroup end
endif

" Auto resize all windows
augroup AutoResize
    autocmd!
    autocmd VimResized * wincmd =
augroup end

" TODO: check this in the future
" augroup AutoSaveAndRead
"     autocmd!
"     autocmd TextChanged,InsertLeave,FocusLost * silent! wall
"     autocmd CursorHold * silent! checktime
" augroup end

augroup LastEditPosition
    autocmd!
    autocmd BufReadPost *
                \   if line("'\"") > 1 && line("'\"") <= line("$") && &ft != "gitcommit" |
                \       exe "normal! g'\""                                               |
                \   endif
augroup end

" TODO To be improve
function! s:CleanFile()
    " Sometimes we don't want to remove spaces
    let l:buftypes = 'nofile\|help\|quickfix\|terminal'
    let l:filetypes = 'bin\|hex\|log\|git\|man\|terminal'

    if b:trim != 1 || &buftype =~? l:buftypes || &filetype ==? l:filetypes || &filetype ==? ''
        return
    endif

    "Save last cursor position
    let l:savepos = getpos('.')
    " Save last search query
    let l:oldquery = getreg('/')

    " Cleaning line endings
    execute '%s/\s\+$//e'
    call histdel('search', -1)

    " Yep I some times I copy this things form the terminal
    silent! execute '%s/\(\s\+\)┊/\1 /ge'
    call histdel('search', -1)

    if &fileformat ==# 'unix'
        silent! execute '%s/\r$//ge'
        call histdel('search', -1)
    endif

    " Config dosini files must trim leading spaces
    if &filetype ==# 'dosini'
        silent! execute '%s/^\s\+//e'
        call histdel('search', -1)
    endif


    call setpos('.', l:savepos)
    call setreg('/', l:oldquery)
endfunction

" Trim whitespace in selected files
augroup CleanFile
    autocmd!
    autocmd BufNewFile,BufRead,BufEnter * if !exists('b:trim') | let b:trim = 1 | endif
    autocmd BufWritePre                 * call s:CleanFile()
augroup end

" Specially helpful for html and xml
augroup MatchChars
    autocmd!
    autocmd FileType xml,html autocmd BufReadPre <buffer> setlocal matchpairs+=<:>
augroup end

augroup QuickQuit
    autocmd!
    autocmd BufEnter,BufReadPost __LanguageClient__ nnoremap <silent> <buffer> q :q!<CR>
    if has('nvim')
        autocmd TermOpen    *        nnoremap <silent> <buffer> q :q!<CR>
    endif
augroup end

augroup LocalCR
    autocmd!
    autocmd CmdwinEnter * nnoremap <CR> <CR>
augroup end

augroup FileTypeDetect
    autocmd!
    autocmd BufRead,BufNewFile    *.bash*         setlocal filetype=sh
    autocmd BufNewFile,BufReadPre /*/nginx/*.conf setlocal filetype=nginx
augroup end

" if exists("g:minimal")
"     " *currently no all functions work
"     augroup omnifuncs
"         autocmd!
"         autocmd FileType css           setlocal omnifunc=csscomplete#CompleteCSS
"         autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
"         autocmd FileType javascript    setlocal omnifunc=javascriptcomplete#CompleteJS
"         autocmd FileType xml           setlocal omnifunc=xmlcomplete#CompleteTags
"         autocmd FileType python        setlocal omnifunc=pythoncomplete#Complete
"         autocmd FileType go            setlocal omnifunc=go#complete#Complete
"         autocmd FileType cs            setlocal omnifunc=OmniSharp#Complete
"         autocmd FileType php           setlocal omnifunc=phpcomplete#CompletePHP
"         autocmd FileType java          setlocal omnifunc=javacomplete#Complete
"         autocmd FileType cpp           setlocal omnifunc=ccomplete#Complete
"         autocmd FileType c             setlocal omnifunc=ccomplete#Complete
"     augroup end
" endif

" Spell {{{
augroup Spells
    autocmd!
    autocmd FileType                    tex      setlocal spell complete+=k,kspell " Add spell completion
    autocmd BufNewFile,BufRead,BufEnter *.org    setlocal spell complete+=k,kspell " Add spell completion
augroup end
" }}} EndSpell

" Skeletons {{{
" TODO: Improve personalization of the templates
" TODO: Create custom cmd

function! CHeader()

    let l:file_name = expand('%:t:r')
    let l:extension = expand('%:e')

    let l:upper_name = toupper(l:file_name)

    if l:extension =~# '^hpp$'
        execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.hpp')
        execute '%s/NAME_HPP/'.l:upper_name.'_HPP/g'
    else
        execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.h')
        execute '%s/NAME_H/'.l:upper_name.'_H/g'
    endif

endfunction

function! CMainOrFunc()

    let l:file_name = expand('%:t:r')
    let l:extension = expand('%:e')

    if l:extension =~# '^cpp$'
        if l:file_name =~# '^main$'
            let l:skeleton = fnameescape(g:parent_dir.'skeletons/main.cpp')
        else
            let l:skeleton = fnameescape(g:parent_dir.'skeletons/skeleton.cpp')
        endif
    elseif l:extension =~# '^c'
        if l:file_name =~# '^main$'
            let l:skeleton = fnameescape(g:parent_dir.'skeletons/main.c')
        else
            let l:skeleton = fnameescape(g:parent_dir.'skeletons/skeleton.c')
        endif
    elseif l:extension =~# '^go'
        if l:file_name =~# '^main$'
            let l:skeleton = fnameescape(g:parent_dir.'skeletons/main.go')
        else
            let l:skeleton = fnameescape(g:parent_dir.'skeletons/skeleton.go')
        endif
    endif

    execute '0r '.l:skeleton
    execute '%s/NAME/'.l:file_name.'/e'

endfunction

function! FileName(file)
    let l:file_name = expand('%:t:r')
    let l:extension = expand('%:e')

    execute '0r '.fnameescape(g:parent_dir.'skeletons/'.a:file)
    execute '%s/NAME/'.l:file_name.'/e'
endfunction

augroup Skeletons
    autocmd!
    autocmd BufNewFile .projections.json  silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/projections.json')
    autocmd BufNewFile *.css              silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.css')
    autocmd BufNewFile *.html             silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.html')
    autocmd BufNewFile *.md               silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.md')
    autocmd BufNewFile *.js               silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.js')
    autocmd BufNewFile *.xml              silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.xml')
    autocmd BufNewFile *.py               silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.py')
    autocmd BufNewFile *.cs               silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.cs')
    autocmd BufNewFile *.php              silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.php')
    autocmd BufNewFile *.sh               silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.sh')
    autocmd BufNewFile *.java             silent! call FileName('skeleton.java')
    autocmd BufNewFile *.vim              silent! call FileName('skeleton.vim')
    autocmd BufNewFile *.go               silent! call CMainOrFunc()
    autocmd BufNewFile *.cpp              silent! call CMainOrFunc()
    autocmd BufNewFile *.hpp              silent! call CHeader()
    autocmd BufNewFile *.c                silent! call CMainOrFunc()
    autocmd BufNewFile *.h                silent! call CHeader()
augroup end

" }}} EndSkeletons

" TODO: Add support for git worktrees
function! s:FindProjectRoot(file)
    let l:root = ''
    let l:markers = ['.git', '.svn', '.hg']

    if exists('g:plugs["vim-fugitive"]')
        let l:root = fugitive#extract_git_dir(fnamemodify(a:file, ':p'))
        if empty(l:root)
            let l:markers = ['.svn', '.hg']
        endif
    endif

    if empty(l:root)
        let l:cwd = fnamemodify(a:file, ':h')
        for l:dir in l:markers
            let l:root = finddir(l:dir, l:cwd.';')
            if !empty(l:root)
                let l:project_root = fnamemodify(l:dir, ':p:h')
                return l:project_root
            endif
        endfor
    endif

    return l:root
endfunction

function! s:SetProjectConfigs()
    let g:project_root =  s:FindProjectRoot(expand('%:p'))
    if !empty(g:project_root)
        let g:project_root = fnamemodify(g:project_root, ':h')

        if filereadable(g:project_root . '/project.vim')
            try
                execute 'source '. g:project_root . '/project.vim'
            catch /.*/
                if !GUI()
                    echoerr 'There were errors with the project file in ' . g:project_root . '/project.vim'
                endif
            endtry
        endif

        if exists('g:plugs["ultisnips"]')
            command! UltiSnipsDir call mkdir(g:project_root . '/UltiSnips', 'p')

            let g:UltiSnipsSnippetsDir        = g:project_root . '/UltiSnips'
            let g:UltiSnipsSnippetDirectories = [
                        \   g:project_root . '/UltiSnips',
                        \   g:base_path . 'config/UltiSnips',
                        \   'UltiSnips'
                        \]
        endif

        if exists('g:plugs["ctrlp"]')
            let g:ctrlp_clear_cache_on_exit = 1
        endif

        if exists('g:plugs["projectile.nvim"]')
            if executable('git')
                let g:projectile#search_prog = 'git grep'
            elseif executable('ag')
                let g:projectile#search_prog = 'ag'
            elseif has('unix')
                let g:projectile#search_prog = 'grep'
            elseif WINDOWS() && !executable('grep')
                let g:projectile#search_prog = 'findstr '
            endif
        endif

        if exists('g:plugs["deoplete.nvim"]') && ( exists('g:plugs["deoplete-clang"]') || exists('g:plugs["deoplete-clang2"]') )
            if filereadable(g:project_root . '/compile_commands.json')
                let g:deoplete#sources#clang#clang_complete_database = g:project_root
            else
                if exists('g:deoplete#sources#clang#clang_complete_database')
                    unlet g:deoplete#sources#clang#clang_complete_database
                endif
            endif
        endif

        if exists('g:plugs["vim-grepper"]')
            let g:grepper.tools = []
            let g:grepper.operator.tools = []

            if executable('git')
                let g:grepper.tools += ['git']
                let g:grepper.operator.tools += ['git']
            endif

            if executable('rg')
                let g:grepper.tools += ['rg']
                let g:grepper.operator.tools += ['rg']
            endif
            if executable('ag')
                let g:grepper.tools += ['ag']
                let g:grepper.operator.tools += ['ag']
            endif
            if executable('grep')
                let g:grepper.tools += ['grep']
                let g:grepper.operator.tools += ['grep']
            endif
            if executable('findstr')
                let g:grepper.tools += ['findstr']
                let g:grepper.operator.tools += ['findstr']
            endif
        else
            if executable('git')
                let &grepprg=GrepTool('git', 'grepprg')
            elseif executable('rg')
                let &grepprg=GrepTool('rg', 'grepprg')
            elseif executable('ag')
                let &grepprg=GrepTool('ag', 'grepprg')
            elseif executable('grep')
                let &grepprg=GrepTool('grep', 'grepprg')
            elseif executable('findstr')
                let &grepprg=GrepTool('findstr', 'grepprg')
            endif
        endif
    else
        let g:project_root = fnamemodify(getcwd(), ':p')

        if filereadable(g:project_root . '/project.vim')
            try
                execute 'source '. g:project_root . '/project.vim'
            catch /.*/
                if !GUI()
                    echoerr 'There were errors with the project file in ' . g:project_root . '/project.vim'
                endif
            endtry
        endif

        if exists('g:plugs["ultisnips"]')
            silent! delcommand UltiSnipsDir
            let g:UltiSnipsSnippetsDir        = g:base_path . 'config/UltiSnips'
            let g:UltiSnipsSnippetDirectories = [g:base_path . 'config/UltiSnips', 'UltiSnips']
        endif

        if exists('g:plugs["ctrlp"]')
            let g:ctrlp_clear_cache_on_exit = (g:ctrlp_user_command.fallback =~# '^ag ')
        endif

        if exists('g:plugs["projectile.nvim"]')
            if executable('ag')
                let g:projectile#search_prog = 'ag'
            elseif has('unix')
                let g:projectile#search_prog = 'grep'
            elseif WINDOWS() && !executable('grep')
                let g:projectile#search_prog = 'findstr '
            endif
        endif

        if exists('g:plugs["deoplete.nvim"]') && ( exists('g:plugs["deoplete-clang"]') || exists('g:plugs["deoplete-clang2"]') )
            if filereadable(g:project_root . '/compile_commands.json')
                let g:deoplete#sources#clang#clang_complete_database = g:project_root
            else
                if exists('g:deoplete#sources#clang#clang_complete_database')
                    unlet g:deoplete#sources#clang#clang_complete_database
                endif
            endif
        endif

        if exists('g:plugs["vim-grepper"]')
            let g:grepper.tools = []
            let g:grepper.operator.tools = []

            if executable('rg')
                let g:grepper.tools += ['rg']
                let g:grepper.operator.tools += ['rg']
            endif
            if executable('ag')
                let g:grepper.tools += ['ag']
                let g:grepper.operator.tools += ['ag']
            endif
            if executable('grep')
                let g:grepper.tools += ['grep']
                let g:grepper.operator.tools += ['grep']
            endif
            if executable('findstr')
                let g:grepper.tools += ['findstr']
                let g:grepper.operator.tools += ['findstr']
            endif
        else
            if executable('rg')
                let &grepprg=GrepTool('rg', 'grepprg')
            elseif executable('ag')
                let &grepprg=GrepTool('ag', 'grepprg')
            elseif executable('grep')
                let &grepprg=GrepTool('grep', 'grepprg')
            elseif executable('findstr')
                let &grepprg=GrepTool('findstr', 'grepprg')
            endif
        endif
    endif
endfunction

augroup ProjectConfig
    autocmd!
    if has('nvim-0.2')
        autocmd DirChanged * call s:SetProjectConfigs()
    endif
    autocmd VimEnter,SessionLoadPost * call s:SetProjectConfigs()
augroup end

augroup LaTex
    autocmd!
    autocmd FileType tex let b:vimtex_main = 'main.tex'
augroup end
