local sys = require 'sys'
local nvim = require 'nvim'

local mkdir = require('utils.files').mkdir
local is_dir = require('utils.files').is_dir
local executable = require('utils.files').executable

local function isempty(s)
    return (s == nil or s == '') and true or false
end

local dirpaths = {
    backup = 'backupdir',
    swap = 'directory',
    undo = 'undodir',
    cache = '',
    session = '',
}

for dirname, dir_setting in pairs(dirpaths) do
    local config_dir = sys[dirname]
    if not is_dir(config_dir) then
        mkdir(config_dir)
    end
    if not isempty(dir_setting) then
        vim.opt[dir_setting] = config_dir
    end
end

vim.g.lua_complete_omni = 1

vim.g.c_syntax_for_h = 0
vim.g.c_comment_strings = 1
vim.g.c_curly_error = 1
vim.g.c_no_if0 = 0

vim.g.tex_flavor = 'latex'

vim.g.terminal_scrollback_buffer_size = 100000

if vim.g.started_by_firenvim then
    vim.opt.laststatus = 0
elseif nvim.has.option 'winbar' then
    vim.opt.laststatus = 3
    vim.opt.winbar = '%=%m %f'
else
    vim.opt.laststatus = 2
end

vim.opt.shada = { '!', '/1000', "'1000", '<1000', ':1000', 's10000', 'h' }

if sys.name == 'windows' then
    vim.opt.shada:append { 'rA:', 'rB:', 'rC:', 'rC:/Temp' }
else
    vim.opt.shada:append 'r/tmp/'
end

if sys.name == 'windows' then
    vim.opt.swapfile = false
    vim.opt.backup = false
end

-- vim.opt.swapfile = false
-- vim.opt.backup = true
-- vim.opt.writebackup = true
-- vim.opt.backupcopy = 'auto'
vim.opt.undofile = true

vim.opt.expandtab = true
vim.opt.shiftround = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.softtabstop = -1

vim.opt.scrollback = -1
vim.opt.updatetime = 100

vim.opt.sidescrolloff = 5
vim.opt.scrolloff = 1
vim.opt.undolevels = 10000

vim.opt.inccommand = 'split'
vim.opt.winaltkeys = 'no'
vim.opt.virtualedit = 'block'
-- vim.opt.formatoptions = 'tcqrolnj'

vim.opt.complete = { '.', 'w', 'b', 'u', 't' }
vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'noinsert' }
-- vim.opt.tags = { '.git/tags', './tags;', 'tags' }
vim.opt.display = { 'lastline', 'msgsep' }
vim.opt.fileformats = { 'unix', 'dos' }

vim.opt.wildmenu = true
vim.opt.wildmode = 'full'

vim.opt.pumblend = 20
vim.opt.winblend = 10

vim.opt.wildmenu = true
vim.opt.wildmode = 'full'

vim.opt.pumblend = 20
vim.opt.winblend = 10

vim.opt.showbreak = '↪\\'
vim.opt.listchars = { tab = '▸ ', trail = '•', extends = '❯', precedes = '❮' }
vim.opt.cpoptions = 'aAceFs_B'
vim.opt.shortmess:append { a = true, c = true }

vim.opt.lazyredraw = true
vim.opt.showmatch = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.infercase = true
vim.opt.ignorecase = true
vim.opt.smartcase = false

vim.opt.smartindent = true
vim.opt.copyindent = true

vim.opt.expandtab = true

vim.opt.joinspaces = false
vim.opt.showmode = false
vim.opt.visualbell = true

vim.opt.hidden = true

vim.opt.autowrite = true
vim.opt.autowriteall = true
vim.opt.fileencoding = 'utf-8'

vim.opt.pastetoggle = '<f3>'

if vim.g.gonvim_running ~= nil then
    vim.opt.showmode = false
    vim.opt.ruler = false
else
    vim.opt.titlestring = '%t (%f)'
    vim.opt.title = true
end

vim.opt.diffopt:append {
    'vertical',
    'iwhiteall',
    'iwhiteeol',
    'indent-heuristic',
    'hiddenoff',
    'closeoff',
    'algorithm:minimal',
}

if nvim.has { 0, 9 } then
    vim.opt.diffopt:append {
        'linematch:60',
    }
end

vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.list = true
vim.opt.wrap = false
vim.opt.colorcolumn = '80'
vim.opt.numberwidth = 1
vim.opt.foldenable = false
vim.opt.foldmethod = 'syntax'
vim.opt.foldlevel = 99

vim.opt.signcolumn = 'auto:2'

-- TODO: Add support to read and parse local and global git ignore files
local wildignores = {
    '*.spl',
    '*.aux',
    '*.out',
    '*.o',
    '*.pyc',
    '*.gz',
    -- '*.pdf',
    '*.sw',
    '*.swp',
    '*.swap',
    '*.com',
    '*.class',
    '*.slo',
    '*.lo',
    '*.o',
    '*.oarma72smp',
    '*.oppc500',
    '*.oppc',
    '*.opp',
    '*.so',
    '*.lai',
    '*.la',
    '*.a',
    '*.pkl',
    '*cache/*',
    '*__pycache__/*',
}

local no_backup = {
    '.git/*',
    '.clangd/*',
    '.gem/*',
    '.caddir/',
    '.svn/*',
    '*.bin',
    '*.7z',
    '*.dmg',
    '*.gz',
    '*.iso',
    '*.jar',
    '*.rar',
    '*.tar',
    '*.zip',
    '*.exe',
    'TAGS',
    'tags',
    'GTAGS',
    'COMMIT_EDITMSG',
}

vim.opt.wildignore = wildignores
vim.opt.backupskip = vim.list_extend(no_backup, wildignores)

vim.opt.mouse = 'a'
vim.opt.clipboard = { 'unnamedplus', 'unnamed' }

if executable 'nvr' then
    vim.env.nvr = 'nvr --servername ' .. vim.v.servername .. ' --remote-silent'
    vim.env.tnvr = 'nvr --servername ' .. vim.v.servername .. ' --remote-tab-silent'
    vim.env.vnvr = 'nvr --servername ' .. vim.v.servername .. ' -cc vsplit --remote-silent'
    vim.env.snvr = 'nvr --servername ' .. vim.v.servername .. ' -cc split --remote-silent'
end

if not nvim.has { 0, 9 } then
    vim.opt.cscopequickfix = { 's-', 'c-', 'd-', 'i-', 't-', 'e-', 'a-', 'g-' }
end

if nvim.has { 0, 9 } then
    vim.opt.splitkeep = 'screen'
end

vim.diagnostic.config {
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    virtual_text = {
        spacing = 2,
        prefix = '❯',
        -- source = true,
    },
}

local orig_signs_handler = vim.diagnostic.handlers.signs
vim.diagnostic.handlers.signs = {
    show = function(ns, bufnr, diagnostics, opts)
        local max_severity_per_line = {}
        for _, d in pairs(diagnostics) do
            local m = max_severity_per_line[d.lnum]
            if not m or d.severity < m.severity then
                max_severity_per_line[d.lnum] = d
            end
        end

        local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
        orig_signs_handler.show(ns, bufnr, filtered_diagnostics, opts)
    end,
    hide = function(ns, bufnr)
        orig_signs_handler.hide(ns, bufnr)
    end,
}

vim.diagnostic.enable()
vim.diagnostic.show()

local sign_str = 'DiagnosticSign'
for _, level in pairs { 'Error', 'Hint', 'Warn', 'Info' } do
    vim.fn.sign_define(
        sign_str .. level,
        { text = require('utils.functions').get_icon(level:lower()), texthl = sign_str .. level }
    )
end
