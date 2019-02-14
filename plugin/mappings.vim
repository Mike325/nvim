scriptencoding "uft-8"
" HEADER {{{
"
"                               Mapping settings
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

" We just want to source this file once
if exists('g:mappings_loaded') && g:mappings_loaded
    finish
endif

let g:mappings_loaded = 1

nnoremap , :
xnoremap , :

" Similar behavior as C and D
nnoremap Y y$

" Don't visual/select the return character
xnoremap $ $h

" Avoid default Ex mode
" Use gQ instead of plain Q, it has tab completion and more cool things
nnoremap Q o<Esc>

" Preserve cursor position when joining lines
nnoremap J m`J``

" Better <ESC> mappings
imap jj <Esc>

nnoremap <BS> <ESC>
xnoremap <BS> <ESC>

" We assume that if we are running neovim from windows without has#gui we are
" running from cmd or powershell, windows terminal send <C-h> when backspace is press
if has('nvim') && os#name('windows') && !has#gui()
    nnoremap <C-h> <ESC>
    xnoremap <C-h> <ESC>

    " We can't sent neovim to background in cmd or powershell
    nnoremap <C-z> <nop>
endif

" Turn diff off when closiong other windows
nnoremap <silent> <C-w><C-o> :diffoff!<bar>only<cr>
nnoremap <silent> <C-w>o :diffoff!<bar>only<cr>

" Seems like a good idea, may activate it later
" nnoremap <expr> q &diff ? ":diffoff!\<bar>only\<cr>" : "q"

" Move vertically by visual line unless preceded by a count. If a movement is
" greater than 5 then automatically add to the jumplist.
nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

" Jump to the previous mark, as <TAB>
nnoremap <S-tab> <C-o>

xnoremap > >gv
xnoremap < <gv

" I prefer to jump directly to the file line
" nnoremap gf gF

" Echo the relative path and of the file
nnoremap <leader><leader>e :echo expand("%")<CR>

" Very Magic sane regex searches
nnoremap g/ /\v
" nnoremap gs :%s/\v

nnoremap <expr> i mappings#IndentWithI()

if has('nvim') || v:version >= 704
    " Change word under cursor and dot repeat
    nnoremap c* *Ncgn
    nnoremap c# #NcgN
    nnoremap cg* g*Ncgn
    nnoremap cg# g#NcgN
    xnoremap <silent> c "cy/<C-r>c<CR>Ncgn
endif

" Fucking Spanish keyboard
nnoremap ¿ `
xnoremap ¿ `
nnoremap ¿¿ ``
xnoremap ¿¿ ``
nnoremap ¡ ^
xnoremap ¡ ^

" Move to previous file
nnoremap <leader>p <C-^>

" For systems without F's keys (ex. Android)
nnoremap <leader>w :update<CR>

" Close buffer/Editor
nnoremap <leader>q :q!<CR>

" easy dump bin files into hex
nnoremap <leader>x :%!xxd<CR>

" TabBufferManagement {{{

" Buffer movement
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

" Equally resize buffer splits
nnoremap <leader>e <C-w>=

nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt
nnoremap <leader>6 6gt
nnoremap <leader>7 7gt
nnoremap <leader>8 8gt
nnoremap <leader>9 9gt
nnoremap <leader>0 :tablast<CR>
nnoremap <leader><leader>n :tabnew<CR>

xnoremap <leader>1 <ESC>1gt
xnoremap <leader>2 <ESC>2gt
xnoremap <leader>3 <ESC>3gt
xnoremap <leader>4 <ESC>4gt
xnoremap <leader>5 <ESC>5gt
xnoremap <leader>6 <ESC>6gt
xnoremap <leader>7 <ESC>7gt
xnoremap <leader>8 <ESC>8gt
xnoremap <leader>9 <ESC>9gt
xnoremap <leader>0 <ESC>:tablast<CR>

" Use C-p and C-n to move in command's history
cnoremap <C-n> <down>
cnoremap <C-p> <up>

" Repeat last substitution
nnoremap & :&&<CR>
xnoremap & :&&<CR>

" Swap 0 and ^, ^ is them most common line beginning for me
nnoremap 0 ^
nnoremap ^ 0

" }}} EndTabBufferManagement

if has('nvim') || has('terminal')
    tnoremap <ESC> <C-\><C-n>

    command! -nargs=? Terminal call mappings#terminal(<q-args>)

    if has('nvim')
        " Better splits
        nnoremap <A-s> <C-w>s
        nnoremap <A-v> <C-w>v

        " Better terminal access
        nnoremap <A-t> :Terminal<CR>
    endif
endif

if exists('+relativenumber')
    command! RelativeNumbersToggle set relativenumber! relativenumber?
endif

if exists('+mouse')
    command! MouseToggle call mappings#ToggleMouse()
endif

command! ArrowsToggle call mappings#ToggleArrows()
command! -bang BufKill call mappings#BufKill(<bang>0)
command! -bang BufClean call mappings#BufClean(<bang>0)

command! ModifiableToggle setlocal modifiable! modifiable?
command! CursorLineToggle setlocal cursorline! cursorline?
command! ScrollBindToggle setlocal scrollbind! scrollbind?
command! HlSearchToggle   setlocal hlsearch! hlsearch?
command! NumbersToggle    setlocal number! number?
command! PasteToggle      setlocal paste! paste?
command! SpellToggle      setlocal spell! spell?
command! WrapToggle       setlocal wrap! wrap?
command! VerboseToggle    let &verbose=!&verbose | echo "Verbose " . &verbose


if exists('g:gonvim_running')
    command! -nargs=* GonvimSettngs execute('edit ~/.gonvim/setting.toml')
endif

if has('nvim') || v:version >= 704
    " Yes I'm quite lazy to type the cmds
    function! s:Formats(...)
        return ['unix', 'dos', 'mac']
    endfunction

    command! -nargs=? -complete=filetype FileType call mappings#SetFileData('filetype', <q-args>, 'text')
    command! -nargs=? -complete=customlist,s:Formats FileFormat call mappings#SetFileData('fileformat', <q-args>, 'unix')
endif

command! TrimToggle call mappings#Trim()

command! -nargs=? -complete=customlist,tools#spells SpellLang
            \ let s:spell = (empty(<q-args>)) ?  'en' : expand(<q-args>) |
            \ call tools#spelllangs(s:spell) |
            \ unlet s:spell
            " \ execute 'set spelllang?' |

" Avoid dispatch command conflict
" QuickfixOpen
command! -nargs=? Qopen execute((&splitbelow) ? 'botright' : 'topleft' ) . ' copen ' . expand(<q-args>)

if executable('svn')
    command! -nargs=* SVNstatus execute('!svn status ' . <q-args>)
    command! -complete=file -nargs=+ SVN execute('!svn ' . <q-args>)
    command! -complete=file -nargs=* SVNupdate execute('!svn update ' . <q-args>)
    command! -complete=file -bang SVNread execute('!svn revert ' . expand("%")) |
                \ let s:bang = empty(<bang>0) ? '' : '!' |
                \ execute('edit'.s:bang) |
                \ unlet s:bang

endif

" function! s:Scratch(bang, args, range)
"     let s:bang = a:bang
"     if !exists('s:target') || a:bang
"         if bufexists(s:target) || filereadable(s:target)
"             Remove! expand( s:target )
"         endif
"
"         let s:args = expand(a:args)
"         if isdirectory(s:args)
"
"         endif
"         let s:target = fnamemodify(empty(a:args) ? expand($TMPDIR . "/scratch.vim") : expand(a:args), ":p")
"         let s:target = ( fnamemodify(expand( s:target ), ":e") != "vim") ? s:target . ".vim" : s:target
"         unlet s:args
"     endif
"     topleft 18sp expand(s:target)
"     unlet s:bang
" endfunction

" command! -bang -complete=dir -nargs=? Scratch

" function! s:FindProjectRoot()
"     " Statement
" endfunction

" command -nargs=1 -bang -bar -range=0 -complete=custom,s:SubComplete S
"       \ :exec s:subvert_dispatcher(<bang>0,<line1>,<line2>,<count>,<q-args>)

" ####### Fallback Plugin mapping {{{

if !exists('g:plugs["iron.nvim"]') && has#python()
    command! -complete=file -nargs=* Python call mappings#Python(2, <q-args>)
    command! -complete=file -nargs=* Python3 call mappings#Python(3, <q-args>)
endif

if !exists('g:plugs["ultisnips"]') && !exists('g:plugs["vim-snipmate"]')
    inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
    inoremap <silent><CR>    <C-R>=mappings#NextSnippetOrReturn()<CR>
endif

if !exists('g:plugs["vim-bbye"]')
    nnoremap <leader>d :bdelete!<CR>
endif

if !exists('g:plugs["vim-indexed-search"]')
    " nnoremap * *zz
    " nnoremap # #zz
    nnoremap <silent> n :call mappings#NiceNext('n')<cr>
    nnoremap <silent> N :call mappings#NiceNext('N')<cr>
endif

if !exists('g:plugs["vim-unimpaired"]')
    nnoremap [Q :cfirst<CR>
    nnoremap ]Q :clast<CR>
    nnoremap ]q :cnext<CR>
    nnoremap [q :cprevious<CR>

    nnoremap [l :lprevious<CR>
    nnoremap ]l :lnext<CR>
    nnoremap [L :lfirst<CR>
    nnoremap ]L :llast<CR>

    nnoremap [B :bfirst<cr>
    nnoremap ]B :blast<cr>
    nnoremap [b :bprevious<cr>
    nnoremap ]b :bnext<cr>
endif

if !exists('g:plugs["vim-vinegar"]') && !exists('g:plugs["nerdtree"]')
    nnoremap - :Explore<CR>
endif

" if !exists('g:plugs["vim-grepper"]')
"     onoremap igc
"     xnoremap igc
" endif

if !exists('g:plugs["vim-eunuch"]')
    " command! -bang -nargs=1 -complete=file Move
    "             \

    " command! -bang -nargs=1 -complete=file Rename
    "             \

    command! -bang -nargs=1 -complete=dir Mkdir
                \ let s:bang = empty(<bang>0) ? 0 : 1 |
                \ let s:dir = expand(<q-args>) |
                \ if exists('*mkdir') |
                \   call mkdir(fnameescape(s:dir), (s:bang) ? "p" : "") |
                \ else |
                \   echoerr "Failed to create dir '" . s:dir . "' mkdir is not available" |
                \ endif |
                \ unlet s:bang |
                \ unlet s:dir

    command! -bang -nargs=? -complete=file Remove
                \ let s:bang = empty(<bang>0) ? 0 : 1 |
                \ let s:target = fnamemodify(empty(<q-args>) ? expand("%") : expand(<q-args>), ":p") |
                \ if filereadable(s:target) || bufloaded(s:target) |
                \   if filereadable(s:target) |
                \       if delete(s:target) == -1 |
                \           echoerr "Failed to delete the file '" . s:target . "'" |
                \       endif |
                \   endif |
                \   if bufloaded(s:target) |
                \       let s:cmd = (s:bang) ? "bwipeout! " : "bdelete! " |
                \       try |
                \           execute s:cmd . s:target |
                \       catch /E94/ |
                \           echoerr "Failed to delete/wipe '" . s:target . "'" |
                \       finally |
                \           unlet s:cmd |
                \       endtry |
                \   endif |
                \ elseif isdirectory(s:target) |
                \   let s:flag = (s:bang) ? "rf" : "d" |
                \   if delete(s:target, s:flag) == -1 |
                \       echoerr "Failed to remove '" . s:target . "'" |
                \   endif |
                \   unlet s:flag |
                \ else |
                \   echoerr "Failed to remove '" . s:target . "'" |
                \ endif |
                \ unlet s:bang |
                \ unlet s:target
endif

if !exists('g:plugs["vim-fugitive"]') && executable('git')
    " TODO: Git pull command
    if has('nvim')
        command! -nargs=+ Git execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split term://git ' . <q-args>)
        command! -nargs=* Gstatus execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split term://git status ' . <q-args>)
        command! -nargs=* Gcommit execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split term://git commit ' . <q-args>)
        command! -nargs=* Gpush  execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split term://git push ' .<q-args>)
        command! -nargs=* Gpull  execute('!git pull ' .<q-args>)
        command! -nargs=* Gwrite  execute('!git add ' . expand("%") . ' ' .<q-args>)
        command! -bang Gread execute('!git reset HEAD ' . expand("%") . ' && git checkout -- ' . expand("%")) |
                    \ let s:bang = empty(<bang>0) ? '' : '!' |
                    \ execute('edit'.s:bang) |
                    \ unlet s:bang
    else
        if has('terminal')
            command! -nargs=+ Git     term_start('git ' . <q-args>, {'       term_rows': 20})
            command! -nargs=* Gstatus term_start('git status ' . <q-args>, {'term_rows': 20})
            command! -nargs=* Gpush   term_start('git push ' .<q-args>, {'   term_rows': 20})
        else
            command! -nargs=+ Git     execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split gitcmd | 0,$delete | 0read !git ' . <q-args>)
            command! -nargs=* Gstatus execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split gitcmd | 0,$delete | 0read !git status ' . <q-args>)
            command! -nargs=* Gpush   execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split gitcmd | 0,$delete | 0read !git push ' .<q-args>)
        endif

        command! -nargs=* Gcommit execute('!git commit ' . <q-args>)
        command! -nargs=* Gpull  execute('!git pull ' .<q-args>)
        command! -nargs=* Gwrite  execute('!git add ' . expand("%") . ' ' .<q-args>)
        command! -bang Gread execute('!git reset HEAD ' . expand("%") . ' && git checkout -- ' . expand("%")) |
                    \ let s:bang = empty(<bang>0) ? '' : '!' |
                    \ execute('edit'.s:bang) |
                    \ unlet s:bang
    endif


    nnoremap <leader>gw :Gwrite<CR>
    nnoremap <leader>gs :Gstatus<CR>
    nnoremap <leader>gc :Gcommit<CR>
    nnoremap <leader>gr :Gread<CR>
endif

" if !exists('g:plugs["denite.nvim"]') && !exists('g:plugs["vim-grepper"]')
"     nnoremap gs :set operatorfunc=GrepOperator<cr>g@
"     vnoremap gs :<c-u>call GrepOperator(visualmode())<cr>
"
"     function! GrepOperator(type)
"         if a:type ==# 'v'
"             normal! `<v`>y
"         elseif a:type ==# 'char'
"             normal! `[v`]y
"         else
"             return
"         endif
"
"         silent execute 'grep -nIR ' . shellescape(@@) . ' .'
"     endfunction
" endif

" }}} END Fallback Plugin mapping
