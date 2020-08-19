" vimagit Setttings
" github.com/mike325/.vim

if !has#plugin('vimagit') || exists('g:config_vimagit')
    finish
endif

let g:config_vimagit = 1

let g:magit_stage_hunk_mapping   = 's'
let g:magit_stage_file_mapping   = 'f'
let g:magit_stage_line_mapping   = 'l'
let g:magit_mark_line_mapping    = 'm'
let g:magit_jump_next_hunk       = '\<C-n>'
let g:magit_jump_prev_hunk       = '\<C-p>'
let g:magit_commit_mapping       = 'cc'
let g:magit_commit_amend_mapping = 'ca'
let g:magit_commit_fixup_mapping = 'cf'
let g:magit_close_commit_mapping = 'cu'
let g:magit_reload_mapping       = 'r'
let g:magit_edit_mapping         = 'e'
let g:magit_show_magit_mapping   = '<leader>m'
