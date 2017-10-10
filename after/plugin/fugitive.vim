" ############################################################################
"
"                               YCM extra settings
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

" TODO: put all git dependent file configs here

if exists('g:plugs["YouCompleteMe"]')
    function! SetExtraConf()
        let g:ycm_global_ycm_extra_conf =  fugitive#extract_git_dir(expand('%:p'))

        if g:ycm_global_ycm_extra_conf ==# ''
            let g:ycm_global_ycm_extra_conf = fnameescape(g:base_path . "ycm_extra_conf.py")
        else
            let g:ycm_global_ycm_extra_conf .=  "/ycm_extra_conf.py"
        endif
    endfunction

    call SetExtraConf()

    command! UpdateYCMConf call SetExtraConf()
endif

if exists('g:plugs["neomake"]')
    " Set project specific makers

    let g:new_project_makers =  fugitive#extract_git_dir(expand('%:p'))

    if g:new_project_makers !=# '' && filereadable(g:new_project_makers . "/makers.vim")
        execute 'source '. g:new_project_makers . '/makers.vim'
    endif
endif
