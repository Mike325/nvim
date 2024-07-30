" Mappings Settings
" github.com/mike325/.vim

let s:arrows = -1

function! mappings#general_completion(arglead, cmdline, cursorpos, options) abort
    return filter(a:options, "v:val =~? join(split(a:arglead, '\zs'), '.*')")
endfunction

function! mappings#inside_empty_pairs() abort
    let l:rsp = 0
    let l:pairs = {
        \ '"': '"',
        \ "'": "'",
        \ ')': '(',
        \ '}': '{',
        \ ']': '[',
        \ '>': '<',
        \}
        " \ '(': ')',
        " \ '{': '}',
        " \ '[': ']',
        " \ '<': '>',

    let l:line = nvim_get_current_line()
    let [l:ln, l:col] = nvim_win_get_cursor(0)

    if l:col > 0
        let l:close = l:line[l:col]
        let l:open = l:line[l:col - 1]
        if get(l:pairs, l:close, -1) != -1
            let l:rsp = l:pairs[l:close] == l:open
        endif
    endif

    return l:rsp
endfunction

function! mappings#enter() abort
    let l:snippet = 0

    if has#plugin('snippets.nvim')
        let l:snippet = luaeval("require'snippets'.expand_or_advance(1)")
    elseif has#plugin('ultisnips')
        let l:snippet = UltiSnips#ExpandSnippet()
    endif

    if get(g:,'ulti_expand_res', 0) > 0
        return l:snippet
    elseif has#plugin('snippets.nvim') && l:snippet
        return ''
    elseif pumvisible()
        let l:selected = complete_info()['selected'] !=# '-1'
        if has#plugin('YouCompleteMe')
            call feedkeys("\<C-y>")
            return ''
        elseif has#plugin('nvim-compe')
            return l:selected ? compe#confirm('<CR>') : compe#close('<C-e>')
        elseif has#plugin('completion-nvim')
            if ! l:selected
                call nvim_select_popupmenu_item(-1 , 0, 1, {})
            endif
            call luaeval("require'completion'.confirmCompletion()")
            return l:selected ? "\<C-y>" : ''
        endif

        return "\<C-y>"
    elseif has#plugin('nvim-autopairs')
        return luaeval('require"nvim-autopairs".autopairs_cr()')
    elseif has#plugin('pears.nvim')
        if mappings#inside_empty_pairs()
            call luaeval('require"pears".handle_return(_A)', nvim_get_current_buf())
            return ''
        endif
    elseif has#plugin('delimitMate') && delimitMate#WithinEmptyPair()
        return delimitMate#ExpandReturn()
    elseif has#plugin('ultisnips')
        call UltiSnips#JumpForwards()
        if get(g:, 'ulti_jump_forwards_res', 0) > 0
            return ''
        endif
    endif

    return "\<CR>"
endfunction

function! mappings#tab() abort
    if pumvisible()
        return "\<C-n>"
    endif
    if has#plugin('snippets.nvim')
        let l:snippet = luaeval("require'snippets'.expand_or_advance(1)")
        return ''
    elseif has#plugin('ultisnips')
        call UltiSnips#JumpForwards()
        if get(g:, 'ulti_jump_forwards_res', 0) > 0
            return ''
        endif
    endif
    return "\<TAB>"
endfunction

function! mappings#shifttab() abort
    if pumvisible()
        return "\<C-p>"
    endif
    if has#plugin('ultisnips')
        call UltiSnips#JumpBackwards()
        if get(g:, 'ulti_jump_backwards_res', 0) > 0
            return ''
        endif
    endif
    " TODO
    return ''
endfunction

if has('terminal') || (!has('nvim-0.4') && has('nvim'))
    function! mappings#terminal(cmd) abort
        let l:split = (&splitbelow) ? 'botright' : 'topleft'

        if !empty(a:cmd)
            let l:shell = a:cmd
        elseif os#name('windows')
            let l:shell = (&shell =~? '^cmd\(\.exe\)\?$') ? 'powershell -noexit -executionpolicy bypass ' : &shell
        else
            let l:shell = fnamemodify(expand($SHELL), ':t')
            if l:shell =~# '\(t\)\?csh'
                let l:shell = (executable('zsh')) ? 'zsh' : (executable('bash')) ? 'bash' : l:shell
            endif
        endif

        if has('nvim')
            execute l:split . ' 20split term://' . l:shell
        else
            call term_start(l:shell . a:cmd, {'term_rows': 20})
        endif

        wincmd J
        setlocal nonumber norelativenumber

        if empty(a:cmd)
            startinsert
        endif

    endfunction
endif

if has#option('mouse')
    function! mappings#ToggleMouse() abort
        if &mouse ==# ''
            execute 'set mouse=a'
            echo 'mouse'
        else
            execute 'set mouse='
            echo 'nomouse'
        endif
    endfunction
endif

if has('nvim') || v:version >= 704
    function! mappings#format(arglead, cmdline, cursorpos) abort
        return mappings#general_completion(a:arglead, a:cmdline, a:cursorpos, ['unix', 'dos', 'mac'])
    endfunction

    function! mappings#SetFileData(action, type, default) abort
        let l:param = (a:type ==# '') ? a:default : a:type
        execute 'setlocal ' . a:action . '=' . l:param
    endfunction
endif

if !has#plugin('iron.nvim') && has#python()
    function! mappings#Python(version, args) abort

        let l:python3 = exists('g:python3_host_prog') ? g:python3_host_prog : has#func('exepath') ? exepath('python3') : 'python3'
        let l:python2 = exists('g:python_host_prog') ? g:python_host_prog : has#func('exepath') ? exepath('python2') : 'python2'

        let l:version = ( a:version  == 3 ) ? l:python3 : l:python2
        if empty(l:version)
            call tools#echoerr('Python' . a:version . ' is not available in the system')
            return -1
        endif
        let l:split = (&splitbelow) ? 'botright' : 'topleft'

        if has('nvim')
            execute l:split . ' 20split term://'. l:version . ' ' . a:args
        elseif has('terminal')
            if empty(a:args)
                call term_start(l:version, {'term_rows': 20})
            else
                call term_start(l:version. ' ' . a:args, {'term_rows': 20})
            endif
            wincmd J
        endif

    endfunction
endif

if !has#plugin('vim-indexed-search')
    " Center searches results
    " CREDITS: https://amp.reddit.com/r/vim/comments/4jy1mh/slightly_more_subltle_n_and_n_behavior/
    function! mappings#NiceNext(cmd) abort
        let view = winsaveview()
        execute 'silent! normal! ' . a:cmd
        if view.topline != winsaveview().topline
            silent! normal! zz
        endif
    endfunction
endif


function! mappings#Trim() abort
    " Since default is to trim, the first call is to deactivate trim
    if b:trim == 0
        let b:trim = 1
        echo ' Trim'
    else
        let b:trim = 0
        echo ' NoTrim'
    endif

    return 0
endfunction

function! mappings#bs() abort
    try
        execute 'pop'
    catch /E\(55\(5\|6\)\|73\|92\)/
        execute "normal! \<C-o>"
    endtry
endfunction

function! mappings#cr() abort
    let l:cword = expand('<cword>')
    try
        execute 'tag ' . l:cword
    catch /E4\(2\(6\|9\)\|33\)/
        execute "silent! normal! \<CR>"
    endtry
endfunction

function! mappings#spells(arglead, cmdline, cursorpos) abort
    let l:candidates = split(glob(vars#basedir() . '/spell/*.utf-8.sug'), '\n')
    let l:candidates = map(l:candidates, {key, val -> split(fnamemodify(val , ':t'), '\.')[0]})
    return mappings#general_completion(a:arglead, a:cmdline, a:cursorpos, l:candidates)
endfunction

" CREDITS: https://github.com/alexlafroscia/dotfiles/blob/master/nvim/init.vim
" Smart indent when entering insert mode with i on empty lines
function! mappings#IndentWithI() abort
    if len(getline('.')) == 0 && line('.') != line('$') && &buftype !~? 'terminal'
        return '"_ddO'
    endif
    return 'i'
endfunction

" Remove buffers
"
" BufKill  will wipe all hidden buffers
" BufKill! will wipe all unloaded buffers
"
" CREDITS: https://vimrcfu.com/snippet/154
function! mappings#BufKill(bang) abort
    let l:count = 0
    for l:b in range(1, bufnr('$'))
        if bufexists(l:b) && (!buflisted(l:b) || (a:bang && !bufloaded(l:b)))
            execute 'bwipeout! '.l:b
            let l:count += 1
        endif
    endfor
    echomsg 'Deleted ' . l:count . ' buffers'
endfunction

" Clean buffer list
"
" BufClean  will delete all non active buffers
" BufClean! will wipe all non active buffers
function! mappings#BufClean(bang) abort
    let l:count = 0
    for l:b in range(1, bufnr('$'))
        if bufexists(l:b) && ( (a:bang && !buflisted(l:b)) || (!a:bang && !bufloaded(l:b) && buflisted(l:b)) )
            execute ( (a:bang) ? 'bwipeout! ' : 'bdelete! ' ) . l:b
            let l:count += 1
        endif
    endfor
    echomsg 'Deleted ' . l:count . ' buffers'
endfunction

" Test remap arrow keys
function! mappings#ToggleArrows() abort
    let s:arrows = s:arrows * -1
    if s:arrows == 1
        nnoremap <left>  <c-w><
        nnoremap <right> <c-w>>
        nnoremap <up>    <c-w>+
        nnoremap <down>  <c-w>-
    else
        unmap <left>
        unmap <right>
        unmap <up>
        unmap <down>
    endif
endfunction

function! mappings#ConncallLevel(level) abort
    let l:level = (!empty(a:level)) ? a:level : (&conceallevel > 0) ? 0 : 2
    let &conceallevel = l:level
endfunction

function! mappings#find(glob) abort
    let l:glob = "'" . a:glob . "'"
    let l:cmd = tools#select_filelist(0)
    if l:cmd =~# '^rg'
        let l:cmd = l:cmd . ' --iglob=' . l:glob
    elseif l:cmd =~# '^fd'
        let l:cmd = l:cmd . ' --glob ' . l:glob . ' .'
    elseif l:cmd =~# '^find'
        let l:cmd = l:cmd . ' -iname=' . l:glob
    else
        let l:cmd = l:cmd . l:glob
    endif

    let l:results = systemlist(l:cmd)
    if v:shell_error == 0
        if len(l:results) > 0
            call qf#dump_files(l:results)
        else
            echomsg "No matches found for " . a:glob
        endif
    else
        call tools#echoerr("Failed to execute find")
    endif
endfunction

function! mappings#edit(args) abort
    for l:glob in a:args
        if filereadable(l:glob)
            execute 'edit ' . l:glob
        elseif l:glob =~? '\*'
            let l:files = glob(l:glob, 0, 1, 0)
            for l:file in l:files
                if filereadable(l:file)
                    execute 'edit ' . l:file
                endif
            endfor
        endif
    endfor
endfunction
