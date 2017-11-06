" ############################################################################
"
"                               Vim Go settings
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

if  !exists('g:plugs["vim-go"]')
    finish
endif

let g:go_textobj_enabled = 1

let g:go_auto_sameids               = 1
let g:go_highlight_functions        = 1
let g:go_highlight_methods          = 1
let g:go_highlight_fields           = 1
let g:go_gocode_unimported_packages = 1

" NOTE: Disable this if Vim becomes slow while editing Go files
let g:go_highlight_types            = 1
let g:go_highlight_operators        = 1

" There's no need to have 2 autoforma running
if exists('g:plugs["vim-autoformat"]')
    let g:go_fmt_autosave = 0
endif

" YouCompleteMe already define <C-]> mappings
if exists('g:plugs["YouCompleteMe"]')
    let g:go_def_mapping_enabled = 0
endif