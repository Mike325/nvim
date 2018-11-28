" ############################################################################
"
"                             Plugin installation
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

" Improve compatibility between Unix and DOS platfomrs {{{

let mapleader="\<Space>"

if os#name('windows')
    " On windows, if gvim.exe or nvim-qt are executed from cygwin, the shell
    " needs to be set to cmd since most plugins expect it for windows.
    set shell=cmd.exe

    " set shell=powershell.exe\ -NoLogo\ -NoProfile\ -NonInteractive\ -ExecutionPolicy\ RemoteSigned
    " " if shellcmdflag starts with '-' then tempname() uses forward slashes, see
    " " https://groups.google.com/forum/#!topic/vim_dev/vTR05EZyfE0
    " set shellcmdflag=-Command
    " set shellquote="
    " set shellxquote=(
    " let &shellpipe='| Out-File -Encoding UTF8 %s'
    " let &shellredir='| Out-File -Encoding UTF8 %s'

    " Better compatibility with Unix paths in DOS systems
    if exists('+shellslash')
        set shellslash
    endif
endif

" }}} END Improve compatibility between Unix and DOS platfomrs

" Initialize plugins {{{

" If there are no plugins available and we don't have git
" fallback to minimal mode
if !executable('git') && !isdirectory(fnameescape(vars#basedir().'plugged'))
    let g:minimal = 1
endif

" TODO: Should minimal include lightweight tpope's plugins ?
" TODO: Check for $TERM before load some configurations
if !exists('g:minimal')

    execute 'set runtimepath^=' . expand(vars#basedir() . '/plug/')

    try
        call execute('set rtp^=' . expand(vars#basedir() . '/plug/'))
        call plug#begin(vars#basedir().'plugged')
    catch
        " Fallback if we fail to init Plug
        if !has('nvim') && v:version >= 800
            packadd! matchit
        elseif !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
            runtime! macros/matchit.vim
        endif
        filetype plugin indent on
        finish
    endtry

    if isdirectory(fnameescape(vars#basedir().'config'))
        Plug fnameescape(vars#basedir().'config')
    endif

    if isdirectory(fnameescape(vars#basedir().'host'))
        Plug fnameescape(vars#basedir().'host')
    endif

    " ####### Colorschemes {{{

    " Plug 'morhetz/gruvbox'
    " Plug 'sickill/vim-monokai'
    " Plug 'nanotech/jellybeans.vim'
    " Plug 'whatyouhide/vim-gotham'
    " Plug 'joshdick/onedark.vim'
    Plug 'ayu-theme/ayu-vim'

    " }}} END Colorschemes

    " ####### Syntax {{{

    Plug 'elzr/vim-json'
    Plug 'tbastos/vim-lua'
    Plug 'peterhoeg/vim-qml'
    Plug 'tpope/vim-markdown'
    Plug 'PProvost/vim-ps1'
    " Plug 'ekalinin/Dockerfile.vim', {'for': 'dockerfile'}
    " Plug 'bjoernd/vim-syntax-simics', {'for': 'simics'}
    " Plug 'kurayama/systemd-vim-syntax', {'for': 'systemd'}
    " Plug 'mhinz/vim-nginx', {'for': 'nginx'}

    if has('nvim') && has#python('3')
        Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}
        " Plug 'blahgeek/neovim-colorcoder', {'do': ':UpdateRemotePlugins'}
        " Plug 'arakashic/chromatica.nvim', {'do': ':UpdateRemotePlugins'}
    endif

    Plug 'octol/vim-cpp-enhanced-highlight'

    " }}} END Syntax

    " ####### Project base {{{

    Plug 'tpope/vim-projectionist'

    " Plug 'xolox/vim-misc'
    " Plug 'xolox/vim-session', {'on': ['OpenSession', 'SaveSession', 'DeleteSession']}


    " Project standardize file settings
    " Plug 'editorconfig/editorconfig-vim'

    " Easy alignment
    " Plug 'godlygeek/tabular'

    " Easy alignment with motions and text objects
    Plug 'tommcdo/vim-lion'

    " Have some problmes with vinager in windows
    if !os#name('windows')
        Plug 'tpope/vim-vinegar'
    " else
    "     Plug 'scrooloose/nerdtree', { 'on': [ 'NERDTree', 'NERDTreeToggle' ] }
    "     " Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': [ 'NERDTreeToggle' ] }
    endif

    " if executable('ctags')
    "     " Simple view of Tags using ctags
    "     Plug 'majutsushi/tagbar', {'on': ['Tagbar', 'TagbarToggle', 'TagbarOpen']}
    " endif

    " if executable('gtags") && has("cscope')
    "     " Great tag management
    "     Plug 'jsfaint/gen_tags.vim'
    " endif

    " Syntax check
    if has#python()
        if has#async()
            Plug 'neomake/neomake'
        else
            Plug 'vim-syntastic/syntastic'
        endif
    endif

    if has('nvim') && has#python('3')

        Plug 'Shougo/denite.nvim'
        Plug 'raghur/fruzzy', {'do': { -> fruzzy#install()}} " TODO: check how this work
        " Plug 'dunstontc/projectile.nvim'
        " Plug 'chemzqm/denite-git'
    else
        Plug 'mhinz/vim-grepper', { 'on': ['Grepper', '<plug>(GrepperOperator)'] }

        Plug 'ctrlpvim/ctrlp.vim'

        if os#name('unix') && executable('git')
            Plug 'jasoncodes/ctrlp-modified.vim'
        endif

        if has#python('3')

            Plug 'raghur/fruzzy', {'do': { -> fruzzy#install()}} " TODO: check how this work

        elseif has#python()
            " Fast and 'easy' to compile C CtrlP matcher
            if (executable('gcc') || executable('clang')) && empty($NO_PYTHON_DEV) && !os#name('windows')
                " Windows must have msbuild compiler to work, temporally disabled
                Plug 'JazzCore/ctrlp-cmatcher', { 'do': function('plugin#ctrlpmatcher')}
            else
                " Fast matcher for ctrlp
                Plug 'FelikZ/ctrlp-py-matcher'
            endif

            " The fastes matcher (as far as I know) but way more complicated to setup
            " Plug 'nixprime/cpsm'
        endif
    endif

    " }}} END Project base

    " ####### Git integration {{{

    " Plug 'airblade/vim-gitgutter'
    if executable('git') || executable('hg') || executable('svn')
        " These are the only VCS I care, if none is installed, then
        " skip this plugin
        Plug 'mhinz/vim-signify'
    endif

    if executable('git')
        Plug 'tpope/vim-fugitive'
        Plug 'jreybert/vimagit', {'on': ['Magit', 'MagitOnly']}
        " Plug 'sodapopcan/vim-twiggy', {'on': ['Twiggy']}
        " Plug 'gregsexton/gitv', {'on': ['Gitv']}
        if !os#name('windows')
            Plug 'rhysd/committia.vim'
        endif
    endif
    " }}} END Git integration

    " ####### Status bar {{{

    " Vim airline is available for >= Vim 7.4
    if v:version > 703 || has('nvim')
        " TODO: Airline seems to take 2/3 of the startuptime
        "       May look to lighter alternatives
        Plug 'vim-airline/vim-airline'
        Plug 'vim-airline/vim-airline-themes'
        " Plug 'enricobacis/vim-airline-clock'
    endif

    " }}} END Status bar

    " ####### Completions {{{

    Plug 'Raimondi/delimitMate'
    Plug 'tpope/vim-abolish'
    Plug 'honza/vim-snippets'

    if has#python() && (has('nvim') || (v:version >= 704))
        Plug 'SirVer/ultisnips'
    else
        Plug 'MarcWeber/vim-addon-mw-utils'
        Plug 'tomtom/tlib_vim'
        Plug 'garbas/vim-snipmate'
    endif

    let s:ycm_installed = 0
    let s:deoplete_installed = 0
    let s:completor = 0

    " This env var allow us to know if the python version has the dev libs
    if empty($NO_PYTHON_DEV) && has#python() " Python base completions {{{

        " Plug 'OmniSharp/omnisharp-vim', { 'do': function('plugin#omnisharp') }

        " Awesome has#async completion engine for Neovim
        " if has#async() && has#python('3')
        if has('nvim') && has#python('3') && empty($YCM)

            " " TODO: There's no package check
            " if !has('nvim')
            "     Plug 'roxma/nvim-yarp'
            "     Plug 'roxma/vim-hug-neovim-rpc'
            "     set pyxversion=3
            " endif

            " FIXME: Some versions of debian ship neovim 0.1.7 which doesn't work
            "        with latest versions of deoplete
            if has('nvim-0.2')
                Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins'}
            else
                Plug 'Shougo/deoplete.nvim', { 'tag': '2.0', 'do': ':UpdateRemotePlugins', 'frozen' : 1}
            endif

            Plug 'Shougo/neco-vim'

            " TODO: I had had some probles with pysl in windows, so let's
            "       skip it until I can figure it out how to fix this
            if plugin#CheckLanguageServer()
                if has('nvim-0.2')
                    Plug 'autozimu/LanguageClient-neovim', {'branch': 'next', 'do': function('plugin#InstallLanguageClient')}
                else
                    " FIXME: Not fully working with neovim < 0.2.0
                    Plug 'autozimu/LanguageClient-neovim', {'tag': '0.1.66', 'do': function('plugin#InstallLanguageClient'), 'frozen': 1}
                endif
            endif

            if !plugin#CheckLanguageServer('c')
                " C/C++ completion base on clang compiler
                if executable('clang')
                    if os#name('windows')
                        " A bit faster C/C++ completion
                        Plug 'tweekmonster/deoplete-clang2'
                    else
                        " NOTE: Doesn't support windows
                        Plug 'zchee/deoplete-clang'
                        " Plug 'Shougo/neoinclude.vim'
                    endif
                endif
            endif

            if !plugin#CheckLanguageServer('python') || os#name('windows')
                " Python completion
                if has('nvim-0.2')
                    Plug 'zchee/deoplete-jedi'
                else
                    Plug 'zchee/deoplete-jedi', {'commit': '3f510b467baded4279c52147e98f840b53324a8b', 'frozen': 1}
                endif
            endif


            " Go completion
            " TODO: Check Go completion in Windows
            if !plugin#CheckLanguageServer('go') && executable('go') && executable('make')
                Plug 'zchee/deoplete-go', { 'do':function('plugin#GetGoCompletion')}
            endif

            " if executable('php')
            "     Plug 'padawan-php/deoplete-padawan', { 'do': 'composer install' }
            " endif

            " JavaScript completion
            if executable('ternjs')
                Plug 'carlitux/deoplete-ternjs'
            endif

            let s:deoplete_installed = 1

        elseif has#async() && executable('cmake') && (( has('unix') && ( executable('gcc')  || executable('clang') )) ||
                    \ (os#name('windows') && executable('msbuild')))

            Plug 'Valloric/YouCompleteMe', { 'do': function('plugin#YCM') }
            " Plug 'davits/DyeVim'

            " C/C++ project generator
            Plug 'rdnetto/ycm-generator', { 'branch': 'stable' }
            let s:ycm_installed = 1
        elseif has#async()
            " Test new completion has#async framework that require python and vim 8 or
            " Neovim (without python3)
            if plugin#CheckLanguageServer('any')
                Plug 'autozimu/LanguageClient-neovim', {'branch': 'next', 'do': function('plugin#InstallLanguageClient')}
            endif

            Plug 'maralla/completor.vim'
            let s:completor = 1
        endif

        " if ( has('nvim') || ( v:version >= 800 ) || ( v:version >= 704 ) ) &&
        "             \ ( s:ycm_installed==1 || s:deoplete_installed==1 )
        "     " Only works with JDK8!!!
        "     Plug 'artur-shaik/vim-javacomplete2'
        " endif

        if s:ycm_installed==0 && s:deoplete_installed==0
            " Completion for python without engines
            Plug 'davidhalter/jedi-vim'

            " Plug 'Rip-Rip/clang_complete'
        endif

    endif " }}} END Python base completions

    " Vim clang does not require python
    if executable('clang') && s:ycm_installed==0 && s:deoplete_installed==0
        Plug 'justmao945/vim-clang'
    endif

    " Completion without python completion engines ( ycm, deoplete or completer )
    if s:ycm_installed==0 && s:deoplete_installed==0 && s:completor==0
        " Neovim does not support Lua plugins yet
        if has('lua') && !has('nvim') && (v:version >= 704)
            Plug 'Shougo/neocomplete.vim'
        elseif (v:version >= 703) || has('nvim')
            " Plug 'Shougo/neocomplcache.vim'
            Plug 'roxma/SimpleAutoComplPop'

            " Supertab install issue
            " https://github.com/ervandew/supertab/issues/185
            if !has('nvim') && (v:version < 800)
                Plug 'ervandew/supertab'
            endif
        endif
    endif

    " }}} END Completions

    " ####### Languages {{{

    Plug 'tpope/vim-endwise'
    " Plug 'fidian/hexmode'

    if executable('go') && has#async()
        Plug 'fatih/vim-go'
    endif

    " Easy comments
    " TODO check other comment plugins with motions
    Plug 'tomtom/tcomment_vim'
    " Plug 'scrooloose/nerdcommenter'

    if (has('nvim') || (v:version >= 704)) && (executable('tex'))
        Plug 'lervag/vimtex'
    endif

    " }}} END Languages

    " ####### Text objects, Motions and Text manipulation {{{

    if (has('nvim') || (v:version >= 704))
        " Plug 'sickill/vim-pasta'

        Plug 'kana/vim-textobj-user'
        Plug 'kana/vim-textobj-line'
        Plug 'glts/vim-textobj-comment'
        Plug 'michaeljsmith/vim-indent-object'
        Plug 'kana/vim-textobj-entire'
        " Plug 'jceb/vim-textobj-uri'
        " Plug 'whatyouhide/vim-textobj-xmlattr'

        " NOTE: cool text object BUT my fat fingers keep presing 'w' instead of 'e'
        "       useful with formatprg

        " TODO: Solve conflict with comment plugin
        " Plug 'coderifous/textobj-word-column.vim'
    endif

    " JSON text objects
    Plug 'tpope/vim-jdaddy'

    " Better motions
    Plug 'easymotion/vim-easymotion'

    " Surround motions
    Plug 'tpope/vim-surround'

    " Map repeat key . for plugins
    Plug 'tpope/vim-repeat'

    " }}} END Text objects, Motions and Text manipulation

    " ####### Misc {{{

    " Better buffer deletions
    Plug 'moll/vim-bbye', { 'on': [ 'Bdelete' ] }

    " Visual marks
    " Plug 'kshenoy/vim-signature'

    " Override default [i,]i,[I,]I,[d,]d,[D,]D to load the results in the quickfix
    " Plug 'romainl/vim-qlist'

    " Move with indentation
    " NOTE: Deprecated in favor of unimpaired plugin
    " Plug 'matze/vim-move'

    " Easy change text
    " Plug 'AndrewRadev/switch.vim'

    " Simple Join/Split operators
    " Plug 'AndrewRadev/splitjoin.vim'

    " Expand visual regions
    " Plug 'terryma/vim-expand-region'

    " Display indention
    Plug 'Yggdroot/indentLine'

    " Change buffer position in the current layout
    " Plug 'wesQ3/vim-windowswap'

    " Handy stuff to navigate
    Plug 'tpope/vim-unimpaired'

    " Show parameters of the current function
    " Plug 'Shougo/echodoc.vim'

    " TODO: check characters display
    " Plug 'dodie/vim-disapprove-deep-indentation'

    " Better defaults for Vim
    Plug 'tpope/vim-sensible'

    " Improve Path searching
    Plug 'tpope/vim-apathy'

    " Automatically clears search highlight when cursor is moved
    Plug 'junegunn/vim-slash'

    " Print the number of the available buffer matches
    Plug 'henrik/vim-indexed-search'

    " Database management
    Plug 'tpope/vim-dadbod', {'on': ['DB']}

    " Create a new buffer narrowed with the visual selected area
    " Plug 'chrisbra/NrrwRgn', {'on': ['NR', 'NarrowRegion', 'NW', 'NarrowWindow']}

    " Unix commands
    if has('unix')
        Plug 'tpope/vim-eunuch'
    endif

    if has('nvim')
        Plug 'Vigemus/iron.nvim', { 'branch': 'lua/replace' }
    elseif !exists('+terminal')
        " Useful to get the console output in Vim (since :terminal is not enable yet)
        Plug 'tpope/vim-dispatch'
    endif

    " " Visualize undo tree
    " if has#python()
    "     Plug 'sjl/gundo.vim', {'on': ['GundoShow', 'GundoToggle']}
    " endif

    " }}} END Misc

    " Initialize plugin system
    call plug#end()

else
    if !has('nvim') && v:version >= 800
        packadd! matchit
    elseif !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
        runtime! macros/matchit.vim
    endif
endif

filetype plugin indent on

" }}} END Initialize plugins
