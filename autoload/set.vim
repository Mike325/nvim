" ############################################################################
"
"                               settings Setttings
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

function! set#min() abort
    let g:minimal = 1
endfunction

function! set#ignorepatterns() abort " Create Ignore rules {{{
    " Files and dirs we want to ignore in searches and plugins
    " The *.  and */patter/* will be add after
    if filereadable(g:home . '/.config/git/ignore')
        let g:ignore_patterns.grep .= ' --exclude-from=' . g:home . '/.config/git/ignore'
        " TODO: Check if ag checks for global ignores
        let g:ignore_patterns.ag .= ' --path-to-ignore ' . g:home . '/.config/git/ignore'
        " ripgrep already check for common global ignores
        " let g:ignore_patterns.rg .= ' --ignore ' . g:home . '/.config/git/ignore'
    endif

    for l:element in g:ignores.vcs
        let g:ignore_patterns.grep .= ' --exclude-dir="*.' . l:element . '" '
    endfor

    for [ l:ignore_type, l:ignore_list ] in items(g:ignores)
        " I don't want to ignore logs here
        if l:ignore_type ==# 'logs' || l:ignore_type ==# 'bin'
            continue
        endif

        for l:item in l:ignore_list
            let l:ignore_pattern = ''

            if l:ignore_type ==# 'vcs'
                let l:ignore_pattern = '.' . l:item . '/*'
            elseif l:ignore_type =~? '_dirs'
                let l:ignore_pattern = l:item . '/*'
            elseif l:ignore_type !=# 'full_name_files'
                let l:ignore_pattern = '*.' . l:item
            else
                let l:ignore_pattern = l:item
            endif

            " let g:ignore_patterns.findstr .= ' /c:' . substitute(l:ignore_pattern, "\(\/\|\*\)", "" ,"g") . ' '

            if l:ignore_type ==# 'vcs' || l:ignore_type =~? '_dirs'
                let g:ignore_patterns.find  .= ' ! -path "*/' . l:ignore_pattern . '" '
            else
                let g:ignore_patterns.find  .= ' ! -iname "' . l:ignore_pattern . '" '
            endif
            " TODO: Make this crap work in Windows
            " let g:ignore_patterns.dir  .= ' '

            " Add both versions, normal and hidden versions
            if l:ignore_type =~? '_dirs'
                let l:ignore_pattern = '.' . l:item . '/*'

                let g:ignore_patterns.find  .= ' ! -path "*/' . l:ignore_pattern . '" '
                " TODO: Make this crap work in Windows
                " let g:ignore_patterns.findstr .= ' /c: "' . l:ignore_pattern . '" '
                " let g:ignore_patterns.dir  .= ' '
            endif
        endfor
    endfor

    " Clean settings before assign the ignore stuff, just lazy stuff
    execute 'set wildignore='
    execute 'set backupskip='
    " set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.png,.jpg

    " Set system ignores and skips
    for [ l:ignore_type, l:ignore_list ] in items(g:ignores)
        " I don't want to ignore vcs here
        if l:ignore_type ==# 'vcs'
            continue
        endif

        for l:item in l:ignore_list
            let l:ignore_pattern = ''

            if l:ignore_type =~? '_dirs'
                " Add both versions, normal and hidden
                let l:ignore_pattern = '*/' . l:item . '/*,*/.' . l:item . '/*'
            elseif l:ignore_type !=# 'full_name_files'
                let l:ignore_pattern = '*.' . l:item
            else
                let l:ignore_pattern = l:item
            endif

            " I don't want to ignore logs or sessions files but I don't want
            " to backup them
            if l:ignore_type !=# 'logs' && l:item !=# 'sessions'
                execute 'set wildignore+=' . fnameescape(l:ignore_pattern)
            endif

            execute 'set backupskip+=' . fnameescape(l:ignore_pattern)
        endfor
    endfor

endfunction " }}} END Create Ignore rules

function! set#initconfigs() abort " Vim's InitConfig {{{
    " Hidden path in `g:base_path` with all generated files
    if !exists('g:parent_dir')
        let g:parent_dir = g:base_path . '.resources/'
    endif

    if !exists('g:dirpaths')
        let g:dirpaths = {
                    \   'backup' : 'backupdir',
                    \   'swap' : 'directory',
                    \   'undo' : 'undodir',
                    \   'cache' : '',
                    \   'sessions' : '',
                    \}
    endif

    " Better backup, swap and undos storage
    set backup   " make backup files
    if exists('+undofile')
        set undofile " persistent undos - undo after you re-open the file
    endif

    " Config all
    for [l:dirname, l:dir_setting] in items(g:dirpaths)
        if exists('*mkdir')
            if !isdirectory(fnameescape( g:parent_dir . l:dirname ))
                call mkdir(fnameescape( g:parent_dir . l:dirname ), 'p')
            endif

            if l:dir_setting !=# '' && exists('+' . l:dir_setting)
                execute 'set ' . l:dir_setting . '=' . fnameescape(g:parent_dir . l:dirname)
            endif
        else
            " echoerr "The current dir " . fnameescape(g:parent_dir . l:dirname) . " could not be created"
            " TODO: Display errors/status in the start screen
            " Just a placeholder
        endif
    endfor

    let l:persistent_settings = (has('nvim')) ? 'shada' : 'viminfo'

    " Remember things between sessions
    " !        + When included, save and restore global variables that start
    "            with an uppercase letter, and don't contain a lowercase letter.
    " 'n       + Marks will be remembered for the last 'n' files you edited.
    " <n       + Contents of registers (up to 'n' lines each) will be remembered.
    " sn       + Items with contents occupying more then 'n' KiB are skipped.
    " :n       + Save 'n' Command-line history entries
    " n/info   + The name of the file to use is "/info".
    " no /     + Since '/' is not specified, the default will be used, that is,
    "            save all of the search history, and also the previous search and
    "            substitute patterns.
    " no %     + The buffer list will not be saved nor read back.
    " h        + 'hlsearch' highlighting will not be restored.
    execute 'set ' . l:persistent_settings . "=!,'100,<500,:500,s100,h"
    execute 'set ' . l:persistent_settings . '+=n' . fnameescape(g:parent_dir . l:persistent_settings)
endfunction " }}} END Vim's InitConfig