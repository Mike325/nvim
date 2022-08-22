local sys = require 'sys'
local nvim = require 'neovim'

local clear_lst = require('utils.tables').clear_lst
local executable = require('utils.files').executable
local is_file = require('utils.files').is_file
local writefile = require('utils.files').writefile
local normalize_path = require('utils.files').normalize_path
-- local realpath = require('utils.files').realpath
local basename = require('utils.files').basename
local read_json = require('utils.files').read_json

local set_abbr = require('neovim.abbrs').set_abbr

local noremap = { noremap = true }
local noremap_silent = { noremap = true, silent = true }

if not vim.g.mapleader then
    vim.g.mapleader = ' '
end

set_abbr { mode = 'c', lhs = 'Gti', rhs = 'Git' }
set_abbr { mode = 'c', lhs = 'W', rhs = 'w' }
set_abbr { mode = 'c', lhs = 'Q', rhs = 'q' }
set_abbr { mode = 'c', lhs = 'q1', rhs = 'q!' }
set_abbr { mode = 'c', lhs = 'qa1', rhs = 'qa!' }
set_abbr { mode = 'c', lhs = 'w1', rhs = 'w!' }
set_abbr { mode = 'c', lhs = 'wA!', rhs = 'wa!' }
set_abbr { mode = 'c', lhs = 'wa1', rhs = 'wa!' }
set_abbr { mode = 'c', lhs = 'Qa1', rhs = 'qa!' }
set_abbr { mode = 'c', lhs = 'Qa!', rhs = 'qa!' }
set_abbr { mode = 'c', lhs = 'QA!', rhs = 'qa!' }

vim.keymap.set('c', '<C-n>', '<down>', noremap)
vim.keymap.set('c', '<C-p>', '<up>', noremap)
vim.keymap.set('c', '<C-k>', '<left>', noremap)
vim.keymap.set('c', '<C-j>', '<right>', noremap)

vim.keymap.set('c', '<C-r><C-w>', "<C-r>=escape(expand('<cword>'), '#')<CR>", noremap)

vim.keymap.set('n', ',', ':', noremap)
vim.keymap.set('x', ',', ':', noremap)
vim.keymap.set('n', 'Y', 'y$', noremap)
vim.keymap.set('x', '$', '$h', noremap)
vim.keymap.set('n', 'Q', 'o<ESC>', noremap)
vim.keymap.set('n', 'J', 'm`J``', noremap)
vim.keymap.set('i', 'jj', '<ESC>')
vim.keymap.set('x', '<BS>', '<ESC>', noremap)

vim.keymap.set('n', '<leader>h', '<C-w>h', noremap)
vim.keymap.set('n', '<leader>j', '<C-w>j', noremap)
vim.keymap.set('n', '<leader>k', '<C-w>k', noremap)
vim.keymap.set('n', '<leader>l', '<C-w>l', noremap)

vim.keymap.set('n', '<leader>e', '<C-w>=', noremap)
vim.keymap.set('n', '<leader>1', '1gt', noremap)
vim.keymap.set('n', '<leader>2', '2gt', noremap)
vim.keymap.set('n', '<leader>3', '3gt', noremap)
vim.keymap.set('n', '<leader>4', '4gt', noremap)
vim.keymap.set('n', '<leader>5', '5gt', noremap)
vim.keymap.set('n', '<leader>6', '6gt', noremap)
vim.keymap.set('n', '<leader>7', '7gt', noremap)
vim.keymap.set('n', '<leader>8', '8gt', noremap)
vim.keymap.set('n', '<leader>9', '9gt', noremap)
vim.keymap.set('n', '<leader>0', '<cmd>tablast<CR>', noremap)
vim.keymap.set('n', '<leader><leader>n', '<cmd>tabnew<CR>', noremap)

vim.keymap.set('n', '-', '<cmd>Explore<CR>', noremap)

vim.keymap.set('n', '&', '<cmd>&&<CR>', noremap)
vim.keymap.set('x', '&', '<cmd>&&<CR>', noremap)

vim.keymap.set('n', '/', 'ms/', noremap)
vim.keymap.set('n', 'g/', 'ms/\\v', noremap)
vim.keymap.set('n', '0', '^', noremap)
vim.keymap.set('n', '^', '0', noremap)

vim.keymap.set('n', 'gV', '`[v`]', noremap)

vim.keymap.set('t', '<ESC>', '<C-\\><C-n>', noremap)

vim.keymap.set('n', '<BS>', function()
    local ok, _ = pcall(nvim.ex.pop)
    if not ok then
        local key = nvim.replace_termcodes('<C-o>', true, false, true)
        nvim.feedkeys(key, 'n', true)
        -- local jumps
        -- ok, jumps = pcall(nvim.exec, 'jumps', true)
        -- if ok and #jumps > 0 then
        --     jumps = vim.split(jumps, '\n')
        --     table.remove(jumps, 1)
        --     table.remove(jumps, #jumps)
        --     local current_jump
        --     for i=1,#jumps do
        --         local jump = vim.trim(jumps[i]);
        --         jump = split(jump, ' ');
        --         if jump[1] == 0 then
        --             current_jump = i;
        --         end
        --         jumps[i] = jump;
        --     end
        --     if current_jump > 1 then
        --         local current_buf = nvim.win.get_buf(0)
        --         local jump_buf = jumps[current_jump - 1][4]
        --         if current_buf ~= jump_buf then
        --             if not nvim.buf.is_valid(jump_buf) or not nvim.buf.is_loaded(jump_buf) then
        --                 nvim.ex.edit(jump_buf)
        --             end
        --         end
        --         nvim.win.set_cursor(0, jumps[current_jump - 1][2], jumps[current_jump - 1][3])
        --     end
        -- end
    end
end, { noremap = true, silent = true, desc = 'Return to the last jump/tag' })

local function nicenext(dir)
    local view = vim.fn.winsaveview()
    vim.cmd('silent! normal! ' .. dir)
    if view.topline ~= vim.fn.winsaveview().topline then
        vim.cmd 'silent! normal! zz'
    end
end

vim.keymap.set('n', 'n', function()
    nicenext 'n'
end, { noremap = true, silent = true, desc = 'n and center view' })

vim.keymap.set('n', 'N', function()
    nicenext 'N'
end, { noremap = true, silent = true, desc = 'N and center viwe' })

vim.keymap.set('n', '<S-tab>', '<C-o>', noremap)
vim.keymap.set('x', '<', '<gv', noremap)
vim.keymap.set('x', '>', '>gv', noremap)

vim.keymap.set(
    'n',
    'j',
    [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'j' : 'gj']],
    { noremap = true, expr = true }
)

vim.keymap.set(
    'n',
    'k',
    [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'k' : 'gk']],
    { noremap = true, expr = true }
)

vim.keymap.set('n', '<leader><leader>e', '<cmd>echo expand("%")<CR>', noremap)

vim.keymap.set('n', 'i', function()
    local current_line = vim.fn.line '.'
    local last_line = vim.fn.line '$'
    local buftype = vim.bo.buftype
    if #vim.fn.getline '.' == 0 and last_line ~= current_line and buftype ~= 'terminal' then
        return '"_ddO'
    end
    return 'i'
end, { noremap = true, expr = true, desc = 'Smart insert/indent' })

vim.keymap.set('n', 'c*', 'm`*``cgn', noremap)
vim.keymap.set('n', 'c#', 'm`#``cgN', noremap)
vim.keymap.set('n', 'cg*', 'm`g*``cgn', noremap)
vim.keymap.set('n', 'cg#', 'm`#``cgN', noremap)
vim.keymap.set('x', 'c', [["cy/<C-r>c<CR>Ncgn]], noremap)
vim.keymap.set('n', '¿', '`', noremap)
vim.keymap.set('x', '¿', '`', noremap)
vim.keymap.set('n', '¿¿', '``', noremap)
vim.keymap.set('x', '¿¿', '``', noremap)
vim.keymap.set('n', '¡', '^', noremap)
vim.keymap.set('x', '¡', '^', noremap)

vim.keymap.set('n', '<leader>p', '<C-^>', noremap)

vim.keymap.set('n', '<leader>q', function()
    local tabs = nvim.list_tabpages()
    local wins = nvim.tab.list_wins(0)
    if #wins > 1 and vim.fn.expand '%' ~= '[Command Line]' then
        nvim.win.hide(0)
    elseif #tabs > 1 then
        nvim.ex['tabclose!']()
    else
        nvim.exec('quit!', false)
    end
end, { noremap = true, silent = true, desc = 'Quit/close windows and tabs' })

vim.keymap.set('i', '<C-U>', '<C-G>u<C-U>', noremap)

vim.keymap.set('n', '<leader>d', function()
    require('utils.buffers').delete()
end, { desc = 'Delete current buffer without changing the window layout' })

vim.keymap.set('n', '[Q', ':<C-U>cfirst<CR>zvzz', noremap_silent)
vim.keymap.set('n', ']Q', ':<C-U>clast<CR>zvzz', noremap_silent)
vim.keymap.set('n', '[q', ':<C-U>exe "".(v:count ? v:count : "")."cprevious"<CR>zvzz', noremap_silent)
vim.keymap.set('n', ']q', ':<C-U>exe "".(v:count ? v:count : "")."cnext"<CR>zvzz', noremap_silent)
vim.keymap.set('n', '[L', ':<C-U>lfirst<CR>zvzz', noremap_silent)
vim.keymap.set('n', ']L', ':<C-U>llast<CR>zvzz', noremap_silent)
vim.keymap.set('n', '[l', ':<C-U>exe "".(v:count ? v:count : "")."lprevious"<CR>zvzz', noremap_silent)
vim.keymap.set('n', ']l', ':<C-U>exe "".(v:count ? v:count : "")."lnext"<CR>zvzz', noremap_silent)
vim.keymap.set('n', '[B', ':<C-U>bfirst<CR>zvzz', noremap_silent)
vim.keymap.set('n', ']B', ':<C-U>blast<CR>zvzz', noremap_silent)
vim.keymap.set('n', '[b', ':<C-U>exe "".(v:count ? v:count : "")."bprevious"<CR>', noremap_silent)
vim.keymap.set('n', ']b', ':<C-U>exe "".(v:count ? v:count : "")."bnext"<CR>', noremap_silent)
vim.keymap.set('n', ']<Space>', [[:<C-U>lua require"utils.helpers".add_nl(true)<CR>]], noremap_silent)
vim.keymap.set('n', '[<Space>', [[:<C-U>lua require"utils.helpers".add_nl(false)<CR>]], noremap_silent)
vim.keymap.set('n', ']e', [[:<C-U>lua require"utils.helpers".move_line(true)<CR>]], noremap_silent)
vim.keymap.set('n', '[e', [[:<C-U>lua require"utils.helpers".move_line(false)<CR>]], noremap_silent)
vim.keymap.set('n', '<C-L>', '<cmd>nohlsearch|diffupdate<CR>', noremap_silent)

nvim.command.set('ClearQf', function()
    require('utils.helpers').clear_qf()
end)

nvim.command.set('ClearLoc', function()
    require('utils.helpers').clear_qf(nvim.get_current_win())
end)

vim.keymap.set('n', '<leader><leader>p', function()
    if nvim.t.swap_window == nil then
        nvim.t.swap_window = 1
        nvim.t.swap_cursor = nvim.win.get_cursor(0)
        nvim.t.swap_base_tab = nvim.tab.get_number(0)
        nvim.t.swap_base_win = nvim.tab.get_win(0)
        nvim.t.swap_base_buf = nvim.win.get_buf(0)
    else
        local swap_new_tab = nvim.tab.get_number(0)
        local swap_new_win = nvim.tab.get_win(0)
        local swap_new_buf = nvim.win.get_buf(0)
        if
            swap_new_tab == nvim.t.swap_base_tab
            and swap_new_win ~= nvim.t.swap_base_win
            and swap_new_buf ~= nvim.t.swap_base_buf
        then
            nvim.win.set_buf(0, nvim.t.swap_base_buf)
            nvim.win.set_buf(nvim.t.swap_base_win, swap_new_buf)
            nvim.win.set_cursor(0, nvim.t.swap_cursor)
            nvim.ex['normal!'] 'zz'
        end
        nvim.t.swap_window = nil
        nvim.t.swap_cursor = nil
        nvim.t.swap_base_tab = nil
        nvim.t.swap_base_win = nil
        nvim.t.swap_base_buf = nil
    end
end, { noremap = true, silent = true, desc = 'Mark and swap windows' })

vim.keymap.set('n', '=l', function()
    require('utils.helpers').toggle_qf(vim.api.nvim_get_current_win())
end, { noremap = true, silent = true, desc = 'Toggle location list' })
vim.keymap.set(
    'n',
    '=q',
    require('utils.helpers').toggle_qf,
    { noremap = true, silent = true, desc = 'Toggle quickfix' }
)

nvim.command.set('Terminal', function(opts)
    local cmd = opts.args
    local shell

    if cmd ~= '' then
        shell = cmd
    elseif sys.name == 'windows' then
        if vim.regex([[^cmd\(\.exe\)\?$]]):match_str(vim.opt.shell:get()) then
            shell = 'powershell -noexit -executionpolicy bypass '
        else
            shell = vim.opt.shell:get()
        end
    else
        shell = vim.fn.fnamemodify(vim.env.SHELL or '', ':t')
        if vim.regex([[\(t\)\?csh]]):match_str(shell) then
            shell = executable 'zsh' and 'zsh' or (executable 'bash' and 'bash' or shell)
        end
    end

    local win = require('utils.windows').big_center()

    vim.wo[win].number = false
    vim.wo[win].relativenumber = false

    -- nvim.ex.edit('term://'..)
    vim.fn.termopen(shell)

    if cmd ~= '' then
        nvim.ex.startinsert()
    end
end, { nargs = '*', desc = 'Show big center floating terminal window' })

nvim.command.set('MouseToggle', function()
    if vim.o.mouse == '' then
        vim.o.mouse = 'a'
        print 'Mouse Enabled'
    else
        vim.o.mouse = ''
        print 'Mouse Disbled'
    end
end)

nvim.command.set('BufKill', function(opts)
    local bang = opts.bang
    local count = 0
    for _, buf in pairs(nvim.list_bufs()) do
        if not nvim.buf.is_valid(buf) or (bang and not nvim.buf.is_loaded(buf)) then
            nvim.ex['bwipeout!'](buf)
            count = count + 1
        end
    end
    if count > 0 then
        print(count, 'buffers deleted')
    end
end, { bang = true, nargs = 0 })

nvim.command.set('VerboseToggle', 'let &verbose=!&verbose | echo "Verbose " . &verbose')
nvim.command.set('RelativeNumbersToggle', 'set relativenumber! relativenumber?')
nvim.command.set('ModifiableToggle', 'setlocal modifiable! modifiable?')
nvim.command.set('CursorLineToggle', 'setlocal cursorline! cursorline?')
nvim.command.set('ScrollBindToggle', 'setlocal scrollbind! scrollbind?')
nvim.command.set('HlSearchToggle', 'setlocal hlsearch! hlsearch?')
nvim.command.set('NumbersToggle', 'setlocal number! number?')
nvim.command.set('SpellToggle', 'setlocal spell! spell?')
nvim.command.set('WrapToggle', 'setlocal wrap! wrap?')

nvim.command.set('Trim', function(opts)
    local args = opts.args:lower()
    if args ~= '' and args ~= 'enable' and args ~= 'disable' and args ~= '?' then
        vim.notify('Invalid arg: ' .. args, 'ERROR', { title = 'Trim' })
        return
    end

    local function get_trim_state()
        if vim.t.disable_trim or vim.g.disable_trim then
            print((' Disabled by %s variable'):format(vim.g.disable_trim and 'global' or 'project'))
        else
            print(vim.b.trim and ' Trim' or ' NoTrim')
        end
    end

    if args == '?' then
        get_trim_state()
        return
    end

    local enable
    if args == '' then
        enable = not vim.b.trim
    else
        enable = args == 'enable'
    end

    if opts.bang and enable then
        vim.t.disable_trim = nil
        vim.b.trim = true
    elseif opts.bang and not enable then
        vim.t.disable_trim = true
        vim.b.trim = false
    elseif not opts.bang then
        vim.b.trim = enable
    end

    if args == '' or (enable and (vim.t.disable_trim or vim.g.disable_trim)) then
        get_trim_state()
    end
end, { nargs = '?', complete = _completions.toggle, bang = true })

nvim.command.set('GonvimSettngs', "execute('edit ~/.gonvim/setting.toml')")

nvim.command.set('FileType', function(opts)
    vim.opt_local.filetype = opts.args ~= '' and opts.args or 'text'
end, { nargs = '?', complete = 'filetype' })

nvim.command.set('FileFormat', function(opts)
    vim.opt_local.filetype = opts.args ~= '' and opts.args or 'unix'
end, { nargs = '?', complete = _completions.fileformats })

nvim.command.set('SpellLang', function(opts)
    require('utils.helpers').spelllangs(opts.args)
end, { nargs = '?', complete = _completions.spells })

nvim.command.set(
    'Qopen',
    "execute((&splitbelow) ? 'botright' : 'topleft' ) . ' copen ' . expand(<q-args>)",
    { nargs = '?' }
)

-- TODO: Check for GUIs
if sys.name == 'windows' then
    vim.keymap.set(
        'n',
        '<C-h>',
        '<cmd>call neovim#bs()<CR>',
        { noremap = true, silent = true, desc = 'Same as <BS> mapping' }
    )
    vim.keymap.set('x', '<C-h>', '<cmd><ESC>', { noremap = true, silent = true, desc = 'Same as <BS> mapping' })
    if not vim.g.started_by_firenvim then
        vim.keymap.set('n', '<C-z>', '<nop>', noremap)
    end
else
    nvim.command.set('Chmod', function(opts)
        local mode = opts.args
        if not mode:match '^%d+$' then
            vim.notify('Not a valid permissions mode: ' .. mode, 'ERROR', { title = 'Chmod' })
            return
        end
        local filename = vim.fn.expand '%'
        local chmod = require('utils.files').chmod
        if is_file(filename) then
            chmod(filename, mode)
        end
    end, { nargs = 1 })
end

nvim.command.set('MoveFile', function(opts)
    local new_path = opts.args
    local bang = opts.bang

    local current_path = vim.fn.expand '%:p'
    local is_dir = require('utils.files').is_dir

    if is_file(current_path) and is_dir(new_path) then
        new_path = new_path .. '/' .. vim.fn.fnamemodify(current_path, ':t')
    end

    require('utils.files').rename(current_path, new_path, bang)
end, { bang = true, nargs = 1, complete = 'file' })

nvim.command.set('RenameFile', function(opts)
    local current_path = vim.fn.expand '%:p'
    local current_dir = vim.fn.expand '%:h'
    require('utils.files').rename(current_path, current_dir .. '/' .. opts.args, opts.bang)
end, { bang = true, nargs = 1, complete = 'file' })

nvim.command.set('Mkdir', function(opts)
    vim.fn.mkdir(vim.fn.fnameescape(opts.args), 'p')
end, { nargs = 1, complete = 'dir' })

nvim.command.set('RemoveFile', function(opts)
    local target = opts.args ~= '' and opts.args or vim.fn.expand '%'
    require('utils.files').delete(vim.fn.fnamemodify(target, ':p'), opts.bang)
end, { bang = true, nargs = '?', complete = 'file' })

nvim.command.set('CopyFile', function(opts)
    local src = vim.fn.expand '%:p'
    local dest = opts.fargs[1]
    require('utils.files').copy(src, dest, opts.bang)
end, { bang = true, nargs = 1, complete = 'file' })

nvim.command.set('Grep', function(opts)
    require('utils.functions').send_grep_job(opts.fargs)
end, { nargs = '+' })

nvim.command.set('CFind', function(opts)
    local finder = require('utils.helpers').select_filelist(false, true)
    if finder[1] == 'fd' or finder[1] == 'fdfind' or finder[1] == 'rg' then
        table.insert(finder, '-uuu')
    end
    local find = RELOAD('jobs'):new {
        cmd = vim.list_extend(finder, opts.fargs),
        progress = false,
        opts = {
            stdin = 'null',
        },
        qf = {
            on_fail = {
                open = true,
                jump = false,
            },
            dump = true,
            open = true,
            jump = false,
            context = 'CFinder',
            title = 'CFinder',
            efm = '%f',
        },
    }
    find:start()
end, { bang = true, nargs = '+', complete = 'file' })

vim.keymap.set('n', 'gs', '<cmd>set opfunc=neovim#grep<CR>g@', noremap_silent)
vim.keymap.set('v', 'gs', ':<C-U>call neovim#grep(visualmode(), v:true)<CR>', noremap_silent)
vim.keymap.set('n', 'gss', function()
    require('utils.functions').send_grep_job(vim.fn.expand '<cword>')
end, noremap_silent)

nvim.command.set('Make', function(opts)
    local args = opts.fargs

    local ok, val = pcall(nvim.buf.get_option, 0, 'makeprg')
    local cmd = ok and val or vim.o.makeprg

    if cmd:sub(#cmd, #cmd) == '%' then
        cmd = cmd:gsub('%%', vim.fn.expand '%')
    end

    cmd = cmd .. table.concat(args, ' ')
    RELOAD('utils.functions').async_execute {
        cmd = cmd,
        progress = false,
        auto_close = true,
        context = 'AsyncLint',
        title = 'AsyncLint',
        callback_on_success = function()
            nvim.ex.checktime()
        end,
    }
end, { nargs = '*', desc = 'Async execution of current makeprg' })

if executable 'cscope' then
    local cscope_queries = {
        symbol = 'find s', -- 0
        definition = 'find g', -- 1
        calling = 'find d', -- 2
        callers = 'find c', -- 3
        text = 'find t', -- 4
        file = 'find f', -- 7
        include = 'find i', -- 8
        assing = 'find a', -- 9
    }

    local function cscope(cword, query)
        cword = (cword and cword ~= '') and cword or vim.fn.expand '<cword>'
        query = cscope_queries[query] or 'find g'
        local ok, err = pcall(nvim.ex.cscope, query .. ' ' .. cword)
        if not ok then
            vim.notify('Error!\n' .. err, 'ERROR', { title = 'cscope' })
        end
    end

    for query, _ in pairs(cscope_queries) do
        local cmd = 'C' .. query:sub(1, 1):upper() .. query:sub(2, #query)
        nvim.command.set(cmd, function(opts)
            cscope(opts.args, query)
        end, { nargs = '?', desc = 'cscope commad to find ' .. query .. ' under cursor or arg' })
    end
end

if executable 'scp' then
    local function convert_path(path, send, host)
        path = normalize_path(path)

        local remote_path -- = './'
        local hosts, paths, projects

        local path_json = normalize_path '~/.config/remotes/paths.json'
        if is_file(path_json) then
            local configs = read_json(path_json) or {}
            hosts = configs.hosts or {}
            paths = hosts[host] or configs.paths or {}
            projects = configs.projects or {}
        else
            paths = {}
            projects = {}
        end

        local project = path:match 'projects/([%w%d%.-_]+)'
        if not project then
            for short, full in pairs(projects) do
                if short ~= 'default' and path:match('/(' .. short .. ')[%w%d%.-_]*') then
                    project = full
                    break
                end
            end
            if not project then
                project = nvim.env.PROJECT or projects.default or 'mike'
            end
        end

        for loc, remote in pairs(paths) do
            if loc:match '%%PROJECT' then
                loc = loc:gsub('%%PROJECT', project)
            end
            loc = normalize_path(loc)
            if path:match(loc) then
                local tail = path:gsub(loc, '')
                if remote:match '%%PROJECT' then
                    remote = remote:gsub('%%PROJECT', project)
                end
                remote_path = remote .. '/' .. tail
                break
            end
        end

        if not remote_path then
            remote_path = require('utils.files').basedir(path):gsub(sys.home:gsub('\\', '/'), '.') .. '/'
            if not send then
                remote_path = remote_path .. basename(path)
            end
        end

        return remote_path
    end

    local function remote_cmd(host, send)
        local filename = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
        local foward_slash = sys.name == 'windows' and not vim.opt.shellslash:get()
        if foward_slash then
            filename = filename:gsub('\\', '/')
        end
        local virtual_filename

        if filename:match '^%w+://' then
            local prefix = filename:match '^%w+://'
            filename = filename:gsub('^%w+://', '')
            if prefix == 'fugitive://' then
                filename = filename:gsub('%.git//?[%w%d]+//?', '')
            end
            virtual_filename = vim.fn.tempname()
            if foward_slash then
                virtual_filename = virtual_filename:gsub('\\', '/')
            end
        end

        vim.validate {
            filename = {
                filename,
                function(f)
                    return is_file(f) or virtual_filename
                end,
                'a valid file',
            },
        }

        if virtual_filename and send then
            writefile(virtual_filename, nvim.buf.get_lines(0, 0, -1, true))
            -- else
            --     filename = realpath(normalize_path(filename))
            --     if foward_slash then
            --         filename = filename:gsub('\\', '/')
            --     end
        end

        local remote_path = ('%s:%s'):format(host, convert_path(filename, send, host))
        local rcmd = [[scp -r "%s" "%s"]]
        if send then
            rcmd = rcmd:format(virtual_filename or filename, remote_path)
        else
            rcmd = rcmd:format(remote_path, virtual_filename or filename)
        end
        return rcmd
    end

    local function get_host(host)
        if not host or host == '' then
            host = vim.fn.input('Enter hostname > ', '', 'customlist,v:lua._completions.ssh_hosts_completion')
        end
        return host
    end

    local function remote_file(host, send)
        host = get_host(host)
        if not host or host == '' then
            return
        end
        local cmd = remote_cmd(host, send)
        local sync = RELOAD('jobs'):new {
            cmd = cmd,
            opts = {
                pty = true,
            },
        }
        sync:callback_on_success(function(_)
            nvim.ex.checktime()
        end)
        sync:callback_on_failure(function(job)
            vim.notify(table.concat(job:output(), '\n'), 'ERROR', { title = 'SyncFile' })
        end)
        sync:start()
    end

    nvim.command.set('SendFile', function(opts)
        remote_file(opts.args, true)
    end, {
        nargs = '*',
        complete = _completions.ssh_hosts_completion,
        desc = 'Send current file to a remote location',
    })

    nvim.command.set('GetFile', function(opts)
        remote_file(opts.args, false)
    end, {
        nargs = '*',
        complete = _completions.ssh_hosts_completion,
        desc = 'Get current file from a remote location',
    })

    vim.keymap.set('n', '<leader><leader>s', '<cmd>SendFile<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader><leader>g', '<cmd>GetFile<CR>', { noremap = true, silent = true })
end

nvim.command.set('Scratch', function(opts)
    local ft = opts.args ~= '' and opts.args or vim.bo.filetype
    local scratchs = STORAGE.scratchs
    scratchs[ft] = scratchs[ft] or vim.fn.tempname()
    local buf = vim.fn.bufnr(scratchs[ft], true)

    if ft and ft ~= '' then
        vim.bo[buf].filetype = ft
    end
    vim.bo[buf].bufhidden = 'hide'

    local wins = nvim.tab.list_wins(0)
    local scratch_win

    for _, win in pairs(wins) do
        if nvim.win.get_buf(win) == buf then
            scratch_win = win
            break
        end
    end

    if not scratch_win then
        scratch_win = nvim.open_win(buf, true, { relative = 'editor', width = 1, height = 1, row = 1, col = 1 })
    end

    nvim.set_current_win(scratch_win)
    nvim.ex.wincmd 'K'
end, {
    nargs = '?',
    complete = 'filetype',
    desc = 'Create a scratch buffer of the current or given filetype',
})

nvim.command.set('ConcealLevel', function()
    local conncall = vim.opt_local.conceallevel:get() or 0
    vim.opt_local.conceallevel = conncall > 0 and 0 or 2
end, { desc = 'Toogle conceal level between 0 and 2' })

nvim.command.set('Messages', function(opts)
    local args = opts.args
    if args == '' then
        local messages = nvim.exec('messages', true)
        messages = clear_lst(vim.split(messages, '\n'))

        -- WARN: This is a WA to avoid EFM detecting ^I as part of a file in lua tracebacks
        for idx, msg in ipairs(messages) do
            messages[idx] = nvim.replace_termcodes(msg, true, false, true)
            if msg:match '%^I' and #msg > 2 then
                messages[idx] = msg:gsub('%^I', '')
            end
        end

        vim.fn.setqflist({}, ' ', {
            lines = messages,
            title = 'Messages',
            context = 'Messages',
        })
        nvim.ex.Qopen()
    else
        nvim.ex.messages 'clear'
        local context = vim.fn.getqflist({ context = 1 }).context
        if context == 'Messages' then
            require('utils.helpers').clear_qf()
            nvim.ex.cclose()
        end
    end
end, { nargs = '?', complete = 'messages', desc = 'Populate quickfix with the :messages list' })

if executable 'pre-commit' then
    nvim.command.set('PreCommit', function(opts)
        local args = opts.fargs
        local errorformats = {
            '%f:%l:%c: %t%n %m',
            '%f:%l:%c:%t: %m',
            '%f:%l:%c: %m',
            '%f:%l: %trror: %m',
            '%f:%l: %tarning: %m',
            '%f:%l: %tote: %m',
            '%f:%l:%m',
            '%f: %trror: %m',
            '%f: %tarning: %m',
            '%f: %tote: %m',
            '%f: Failed to json decode (%m: line %l column %c (char %*\\\\d))',
            '%f: Failed to json decode (%m)',
            '%E%f:%l:%c: fatal error: %m',
            '%E%f:%l:%c: error: %m',
            '%W%f:%l:%c: warning: %m',
            'Diff in %f:',
            '+++ %f',
            'reformatted %f',
        }
        local precommit = RELOAD('jobs'):new {
            cmd = 'pre-commit',
            args = args,
            -- progress = true,
            qf = {
                efm = errorformats,
                dump = false,
                on_fail = {
                    dump = true,
                    jump = false,
                    open = true,
                },
                context = 'PreCommit',
                title = 'PreCommit',
            },
        }
        precommit:start()
        -- precommit:progress()
    end, { nargs = '*' })
end

if not vim.env.SSH_CONNECTION then
    nvim.command.set('Open', function(opts)
        require('utils.functions').open(opts.args)
    end, {
        nargs = 1,
        complete = 'file',
        desc = 'Open file in the default OS external program',
    })

    vim.keymap.set('n', 'gx', function()
        local cfile = vim.fn.expand '<cfile>'
        local cword = vim.fn.expand '<cWORD>'
        require('utils.functions').open(cword:match '^[%w]+://' and cword or cfile)
    end, noremap_silent)
end

nvim.command.set('Repl', function(opts)
    local cmd = opts.fargs

    if #cmd == 0 or (#cmd == 1 and cmd[1] == '') then
        if vim.b.relp_cmd then
            cmd = vim.b.relp_cmd
        else
            cmd = vim.opt_local.filetype:get()
        end
    end

    local direction = vim.opt.splitbelow:get() and 'botright' or 'topleft'
    vim.api.nvim_exec(direction .. ' 20new', false)

    local win = vim.api.nvim_get_current_win()

    vim.wo[win].number = false
    vim.wo[win].relativenumber = false

    vim.fn.termopen(type(cmd) == type {} and table.concat(cmd, ' ') or cmd)
    nvim.ex.startinsert()
end, { nargs = '*', complete = 'filetype' })

-- TODO: May need to add a check for "zoom" executable but this should work even inside WSL
nvim.command.set('Zoom', function(opts)
    local links = {}
    if require('utils.files').is_file '~/.config/zoom/links.json' then
        links = require('utils.files').read_json '~/.config/zoom/links.json'
    end

    if links[opts.args] then
        require('utils.functions').open(links[opts.args])
    else
        vim.notify('Missing Zoom link ' .. opts.args, 'ERROR', { title = 'Zoom' })
    end
end, { nargs = 1, complete = _completions.zoom_links, desc = 'Open Zoom call in a specific room' })

vim.keymap.set('n', '=D', function()
    vim.diagnostic.setqflist()
    vim.cmd 'wincmd J'
end, { noremap = true, silent = true, desc = 'Toggle diagnostics in the quickfix' })

vim.opt.formatexpr = [[luaeval('require"utils.buffers".format()')]]
vim.keymap.set(
    'n',
    '=F',
    [[<cmd>normal! gggqG``<CR>]],
    { noremap = true, silent = true, desc = 'Format the current buffer with the prefer formatting prg' }
)

nvim.command.set('Edit', function(args)
    local globs = args.fargs
    for _, g in ipairs(globs) do
        if is_file(g) then
            nvim.ex.edit(g)
        elseif g:match '%*' then
            local files = vim.fn.glob(g, false, true, false)
            for _, f in ipairs(files) do
                if is_file(f) then
                    nvim.ex.edit(f)
                end
            end
        end
    end
end, { nargs = '*', complete = 'file', desc = 'Open multiple files' })

nvim.command.set('DiffFiles', function(args)
    local files = args.fargs
    if #files ~= 2 and #files ~= 3 then
        vim.notify('Can only diff 2 or 3 files files', 'ERROR', { title = 'DiffFiles' })
        return false
    end

    for _, f in ipairs(files) do
        if not is_file(f) then
            vim.notify(f .. ' is not a regular file or the file does not exits', 'ERROR', { title = 'DiffFiles' })
            return false
        end
    end
    local only = true
    for _, f in ipairs(files) do
        if only then
            only = false
            nvim.ex.tabnew()
        else
            nvim.ex.vsplit()
        end
        nvim.ex.edit(f)
    end

    for _, w in ipairs(nvim.tab.list_wins(0)) do
        local buf = nvim.win.get_buf(w)
        nvim.buf.call(buf, function()
            nvim.ex.diffthis()
        end)
    end
end, { nargs = '+', complete = 'file', desc = 'Open a new tab in diff mode with the given files' })

local show_diagnostics = true
local function toggle_diagnostics()
    show_diagnostics = not show_diagnostics
    if show_diagnostics then
        vim.diagnostic.show()
    else
        vim.diagnostic.hide()
    end
end

local function custom_compiler(args)
    local files = RELOAD 'utils.files'

    local path = sys.base .. '/after/compiler/'
    local compiler = args.args
    local compilers = vim.tbl_map(files.basename, files.get_files(path))
    if vim.tbl_contains(compilers, compiler .. '.lua') then
        nvim.command.set('CompilerSet', function(command)
            vim.cmd(('setlocal %s'):format(command.args))
        end, { nargs = 1, buffer = true })

        nvim.ex.luafile(path .. compiler .. '.lua')

        nvim.command.del('CompilerSet', true)
    else
        local language = vim.opt_local.filetype:get()
        local has_compiler, compiler_data = pcall(RELOAD, 'filetypes.' .. language)

        if has_compiler and (compiler_data.makeprg or compiler_data.formatprg) then
            local set_compiler = RELOAD('utils.functions').set_compiler

            if compiler_data.makeprg[compiler] then
                set_compiler(compiler)
            elseif compiler_data.formatprg[compiler] then
                set_compiler(compiler, { option = 'formatprg' })
            else
                has_compiler = not has_compiler
            end
        end

        if not has_compiler then
            nvim.ex.compiler(compiler)
        end
    end
end

-- -- TODO: include a message to indicte the current state
-- vim.keymap.set(
--     'n',
--     '<leader>D',
--     toggle_diagnostics,
--     { noremap = true, silent = true, desc = 'Toggle colum sign diagnostics' }
-- )
nvim.command.set('ToggleDiagnostics', toggle_diagnostics, { desc = 'Toggle column sign diagnostics' })

-- NOTE: I should not need to create this function, but I couldn't find a way to override
--       internal runtime compilers
nvim.command.set('Compiler', custom_compiler, {
    nargs = 1,
    complete = 'compiler',
    desc = 'Set the given compiler with preference on the custom compilers located in the after directory',
})
-- nvim.command.set('CompilerExecute', function(args)
--     local makeprg = vim.opt_local.makeprg:get()
--     local efm = vim.opt_local.errorformat:get()
--
--     custom_compiler(args)
--
--     local cmd = vim.opt_local.makeprg:get()
--
--     async_execute {
--         cmd = cmd,
--         progress = false,
--         context = 'Compiler',
--         title = 'Compiler',
--     }
--
--     vim.opt_local.makeprg = makeprg
--     vim.opt_local.errorformat = efm
-- end, {nargs = 1, complete = 'compiler'})

nvim.command.set('AutoFormat', function()
    vim.b.disable_autoformat = not vim.b.disable_autoformat
    print('Autoformat', vim.b.disable_autoformat and 'disabled' or 'enabled')
end, { desc = 'Toggle Autoformat autocmd' })

local ok, packer = pcall(require, 'packer')
if ok then
    nvim.command.set('CreateSnapshot', function(opts)
        local date = os.date '%Y-%m-%d'
        local raw_ver = nvim.version()
        local version = table.concat({ raw_ver.major, raw_ver.minor, raw_ver.patch }, '.')
        local name = opts.args ~= '' and opts.args or 'clean'
        local snapshot = ('%s-nvim-%s-%s.json'):format(name, version, date)
        packer.snapshot(snapshot)
    end, { nargs = '?', desc = 'Creates a packer snapshot with a standard format' })
end

nvim.command.set('Wall', function(opts)
    for _, win in ipairs(nvim.tab.list_wins(0)) do
        -- local buf = nvim.win.get_buf(win)
        nvim.win.call(win, function()
            nvim.ex.update()
        end)
    end
end, { desc = 'Saves all visible windows' })
