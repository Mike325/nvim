local sys = require'sys'
local nvim = require'neovim'
local plugins = require'neovim'.plugins

local executable       = require'utils.files'.executable
local is_dir           = require'utils.files'.is_dir
local is_file          = require'utils.files'.is_file
local normalize_path   = require'utils.files'.normalize_path
local getcwd           = require'utils.files'.getcwd
local split_components = require'utils.strings'.split_components
local echoerr          = require'utils.messages'.echoerr
local echowarn         = require'utils.messages'.echowarn
local clear_lst        = require'utils.tables'.clear_lst
local get_git_dir      = require'utils.functions'.get_git_dir
local split            = require'utils.strings'.split

local set_abbr = require'neovim.abbrs'.set_abbr

local system = vim.fn.system
local line = vim.fn.line

local M = {}

local abolish = {}

local langservers = {
    python     = {'pyls', 'jedi-language-server'},
    c          = {'clangd', 'ccls', 'cquery'},
    cpp        = {'clangd', 'ccls', 'cquery'},
    cuda       = {'clangd', 'ccls', 'cquery'},
    objc       = {'clangd', 'ccls', 'cquery'},
    objcpp     = {'clangd', 'ccls', 'cquery'},
    sh         = {'bash-language-server'},
    bash       = {'bash-language-server'},
    go         = {'gopls'},
    latex      = {'texlab'},
    tex        = {'texlab'},
    bib        = {'texlab'},
    vim        = {'vim-language-server'},
    lua        = {'sumneko_lua'},
    dockerfile = {'docker-langserver'},
    Dockerfile = {'docker-langserver'},
}

abolish['en'] = {
    ['flase']                                = 'false',
    ['syntaxis']                             = 'syntax',
    ['developement']                         = 'development',
    ['identation']                           = 'indentation',
    ['aligment']                             = 'aliment',
    ['posible']                              = 'possible',
    ['reproducable']                         = 'reproducible',
    ['retreive']                             = 'retrieve',
    ['compeletly']                           = 'completely',
    ['movil']                                = 'mobil',
    ['pro{j,y}ect{o}']                       = 'project',
    ['imr{pov,pvo}e']                        = 'improve',
    ['enviroment{,s}']                       = 'environment{}',
    ['sustition{,s}']                        = 'substitution{}',
    ['sustitution{,s}']                      = 'substitution{}',
    ['aibbreviation{,s}']                    = 'abbreviation{}',
    ['abbrevation{,s}']                      = 'abbreviation{}',
    ['avalib{ility,le}']                     = 'availab{ility,le}',
    ['seting{,s}']                           = 'setting{}',
    ['settign{,s}']                          = 'setting{}',
    ['subtitution{,s}']                      = 'substitution{}',
    ['{despa,sepe}rat{e,es,ed}']             = '{despe,sepa}rat{}',
    ['{despa,sepe}rat{ing,ely,ion,ions,or}'] = '{despe,sepa}rat{}',
    ['{,in}consistant{,ly}']                 = '{}consistent{}',
    ['lan{gauge,gue,guege}']                 = 'language',
    ['lan{guegae,ague,agueg}']               = 'language',
    ['delimeter{,s}']                        = 'delimiter{}',
    ['{,non}existan{ce,t}']                  = '{}existen{}',
    ['d{e,i}screp{e,a}nc{y,ies}']            = 'd{i}screp{a}nc{}',
    ['{,un}nec{ce,ces,e}sar{y,ily}']         = '{}nec{es}sar{}',
    ['persistan{ce,t,tly}']                  = 'persisten{}',
    ['{,ir}releven{ce,cy,t,tly}']            = '{}relevan{}',
    ['cal{a,e}nder{,s}']                     = 'cal{e}ndar{}'
}

abolish['es'] = {
    ['analisis']                      = 'análisis',
    ['artifial']                      = 'artificial',
    ['conexion']                      = 'conexión',
    ['autonomo']                      = 'autónomo',
    ['codigo']                        = 'código',
    ['teoricas']                      = 'teóricas',
    ['disminicion']                   = 'disminución',
    ['adminstracion']                 = 'administración',
    ['relacion']                      = 'relación',
    ['minimo']                        = 'mínimo',
    ['area']                          = 'área',
    ['imagenes']                      = 'imágenes',
    ['arificiales']                   = 'artificiales',
    ['actuan']                        = 'actúan',
    ['basicamente']                   = 'básicamente',
    ['acuardo']                       = 'acuerdo',
    ['carateristicas']                = 'características',
    ['ademas']                        = 'además',
    ['asi']                           = 'así',
    ['siguente']                      = 'siguiente',
    ['automatico']                    = 'automático',
    ['algun']                         = 'algún',
    ['dia{,s}']                       = 'día{}',
    ['pre{sici,cisi}on']              = 'precisión',
    ['pro{j,y}ect{o}']                = 'proyecto',
    ['logic{as,o,os}']                = 'lógic{}',
    ['{h,f}ernandez']                 = '{}ernández',
    ['electronico{,s}']               = 'electrónico{}',
    ['algorimo{,s}']                  = 'algoritmo{}',
    ['podria{,n,s}']                  = 'podría{}',
    ['metodologia{,s}']               = 'metodología{}',
    ['{bibliogra}fia']                = '{}fía',
    ['{reflexi}on']                   = '{}ón',
    ['mo{b,v}il']                     = 'móvil',
    ['{televi,explo}sion']            = '{}sión',
    ['{reac,disminu,interac}cion']    = '{}ción',
    ['{clasifica,crea,notifica}cion'] = '{}ción',
    ['{introduc,justifi}cion']        = '{}ción',
    ['{obten,ora,emo,valora}cion']    = '{}ción',
    ['{utilizap,modifica,sec}cion']   = '{}ción',
    ['{delimita,informa}cion']        = '{}ción',
    ['{fun,administra,aplica}cion']   = '{}ción',
    ['{rala,aproxima,programa}cion']  = '{}ción',
}

local qf_funcs = {
    qf = {
        first = 'cfirst',
        last = 'clast',
        close = 'cclose',
        open = 'Qopen',
        set_list = vim.fn.setqflist,
        get_list = vim.fn.getqflist,
    },
    loc = {
        first = 'lfirst',
        last = 'llast',
        close = 'lclose',
        open = 'lopen',
        set_list = vim.fn.setloclist,
        get_list = vim.fn.getloclist,
    },
}

local icons

-- Separators
-- 
-- 
-- ▶
-- ◀
-- »
-- «
-- ❯
-- ➤
-- 
-- ☰
-- 

if not vim.env['NO_COOL_FONTS'] then
    icons = {
        error = '✗', -- ✗ -- 🞮 -- 
        warn = '',
        info = '',
        hint = '',
        bug = '',
        wait = '☕',
        build = '⛭',
        success = '✔',
        message = 'M',
        virtual_text = '❯',
        diff_add = '',
        diff_modified = '',
        diff_remove = '',
        git_branch = '',
        readonly = '🔒',
        bar = '▋',
        sep_triangle_left = '',
        sep_triangle_right = '',
        sep_circle_right = '',
        sep_circle_left = '',
        sep_arrow_left = '',
        sep_arrow_right = '',
    }
else
    icons = {
        error = '×',
        warn = '!',
        info = 'I',
        hint = 'H',
        bug = 'B',
        build = 'W',
        wait = '...',
        success = ':)',
        message = 'M',
        virtual_text = '➤',
        diff_add = '+',
        diff_modified = '~',
        diff_remove = '-',
        git_branch = '',
        readonly = '',
        bar = '|',
        sep_triangle_left = '>',
        sep_triangle_right = '<',
        sep_circle_right = '(',
        sep_circle_left = ')',
        sep_arrow_left = '>',
        sep_arrow_right = '<',
    }
end

local git_dirs = {}

function M.load_module(name)
    local ok, module = pcall(require, name)
    if not ok then
        return nil
    end
    return module
end

function M.get_separators(sep_type)
    local separators = {
        circle = {
            left = icons.sep_circle_left,
            right = icons.sep_circle_right,
        },
        triangle = {
            left = icons.sep_triangle_left,
            right = icons.sep_triangle_right,
        },
        arrow = {
            left = icons.sep_arrow_left,
            right = icons.sep_arrow_right,
        },
    }

    return separators[sep_type]
end

function M.get_icon(icon)
    return icons[icon]
end

function M.project_config(event)
    -- print(vim.inspect(event))

    local cwd = event.cwd or getcwd()
    cwd = cwd:gsub('\\', '/')

    if vim.b.project_root and vim.b.project_root['cwd'] == cwd then
        return vim.b.project_root
    end

    local root = M.find_project_root(cwd)

    if #root == 0 then
        root = vim.fn.fnamemodify(cwd, ':p')
    end

    root = normalize_path(root)

    if vim.b.project_root and root == vim.b.project_root['root'] then
        return vim.b.project_root
    end

    local is_git = M.is_git_repo(root)
    local git_dir = is_git and git_dirs[cwd] or nil
    -- local filetype = vim.bo.filetype
    -- local buftype = vim.bo.buftype

    vim.b.project_root = {
        cwd = cwd,
        root = root,
        is_git = is_git,
        git_dir = git_dir,
    }

    if is_git and not git_dir and nvim.has('nvim-0.5') then
        get_git_dir(function(dir)
            local project = vim.b.project_root
            project.git_dir = dir
            git_dirs[cwd] = dir
            vim.b.project_root = project
        end)
    end

    if is_git then
        pcall(require'git.commands'.set_commands)
    else
        pcall(require'git.commands'.rm_commands)
    end

    M.set_grep(is_git, true)

    local project = vim.fn.findfile('.project.vim', cwd..';')
    if #project > 0 then
        -- print('Sourcing Project ', project)
        nvim.ex.source(project)
    end

    -- local telescope = M.load_module'plugins/telescope'

    if plugins['ctrlp'] ~= nil then
        local fast_look_up = {
            ag = 1,
            fd = 1,
            rg = 1,
        }
        local fallback = vim.g.ctrlp_user_command.fallback
        local clear_cache = is_git and true or (fast_look_up[fallback] ~= nil and true or false)

        vim.g.ctrlp_clear_cache_on_exit = clear_cache
    end

    if plugins['vim-grepper'] ~= nil then

        local operator = {}
        local utils = {}

        if executable('git') and is_git then
            utils[#utils + 1] = 'git'
            operator[#operator + 1] = 'git'
        end

        if executable('rg') then
            utils[#utils + 1] = 'rg'
            operator[#operator + 1] = 'rg'
        end

        if executable('ag') then
            utils[#utils + 1] = 'ag'
            operator[#operator + 1] = 'ag'
        end

        if executable('grep') then
            utils[#utils + 1] = 'grep'
            operator[#operator + 1] = 'grep'
        end

        if executable('findstr') then
            utils[#utils + 1] = 'findstr'
            operator[#operator + 1] = 'findstr'
        end

        vim.g.grepper = {
            utils = utils,
            operator = {
                utils = operator
            },
        }

    end

    if plugins['gonvim-fuzzy'] ~= nil then
        vim.g.gonvim_fuzzy_ag_cmd = M.select_grep(is_git)
    end

end

function M.add_nl(down)
    local cursor_pos = nvim.win.get_cursor(0)
    local lines = {''}
    local count = vim.v['count1']
    if count > 1 then
        for _=2,count,1 do
            lines[#lines + 1] = ''
        end
    end

    local cmd
    if not down then
        cursor_pos[1] = cursor_pos[1] + count
        cmd = '[ '
    else
        cmd = '] '
    end

    nvim.put(lines, 'l', down, true)
    nvim.win.set_cursor(0, cursor_pos)
    vim.cmd('silent! call repeat#set("'..cmd..'",'..count..')')
end

function M.move_line(down)
    -- local cmd
    local lines = {''}
    local count = vim.v.count1

    if count > 1 then
        for _=2,count,1 do
            lines[#lines + 1] = ''
        end
    end

    if down then
        -- cmd = ']e'
        count = line('$') < line('.') + count and line('$') or line('.') + count
    else
        -- cmd = '[e'
        count = line('.') - count - 1 < 1 and 1 or line('.') - count - 1
    end

    vim.cmd(string.format([[move %s | normal! ==]], count))
    -- TODO: Make repeat work
    -- vim.cmd('silent! call repeat#set("'..cmd..'",'..count..')')
end

function M.find_project_root(path)
    assert(type(path) == 'string' and path ~= '', ([[Not a path: "%s"]]):format(path))
    local root
    local vcs_markers = {'.git', '.svn', '.hg',}
    local dir = vim.fn.fnamemodify(path, ':p')

    for _,marker in pairs(vcs_markers) do
        root = vim.fn.finddir(marker, dir..';')

        if #root == 0 and marker == '.git' then
            root = vim.fn.findfile(marker, dir..';')
            root = #root > 0 and root..'/' or root
        end

        if root ~= '' then
            root = vim.fn.fnamemodify(root, ':p:h:h')
            break
        end
    end

    root = (not root or root == '') and getcwd() or root
    return normalize_path(root)
end

function M.is_git_repo(root)
    assert(
        type(root) == type('') and root ~= '',
        debug.traceback(([[Not a path: "%s"]]):format(root))
    )
    if not executable('git') then
        return false
    end

    root = normalize_path(root)

    local git = root .. '/.git'

    if is_dir(git) or is_file(git) then
        return true
    end
    return vim.fn.findfile('.git', root..';') ~= ''
end

function M.dprint(...)
    print(vim.inspect(...))
end

function M.check_version(sys_version, version_target)
    assert(type(sys_version) == type({}), debug.traceback('System version must be an array'))
    assert(type(version_target) == type({}), debug.traceback('Checking version must be an array'))

    for i,_ in pairs(version_target) do

        if type(version_target[i]) == 'string' then
            version_target[i] = tonumber(version_target[i])
        end

        if type(sys_version[i]) == 'string' then
            sys_version[i] = tonumber(sys_version[i])
        end

        if version_target[i] > sys_version[i] then
            return false
        elseif version_target[i] < sys_version[i] then
            return true
        elseif #version_target == i and version_target[i] == sys_version[i] then
            return true
        end
    end
    return false
end

function M.has_git_version(...)
    if not executable('git') then
        return false
    end

    local args
    if ... == nil or type(...) ~= 'table' then
        args = {...}
    else
        args = ...
    end

    if #STORAGE.git_version == 0 then
        STORAGE.git_version = string.match(system('git --version'), '%d+%p%d+%p%d+')
    end

    if #args == 0 then
        return STORAGE.git_version
    end

    local components = split_components(STORAGE.git_version, '%d+')

    return M.check_version(components, args)
end

function M.ignores(tool)
    local excludes = split(vim.o.backupskip, ',')

    if #excludes == 0 then
        return ''
    end

    local ignores = {
        fd = {},
        find = {'-regextype', 'egrep', '!', [[\(]]},
        rg = {},
        ag = {},
        grep = {},
        findstr = {},
    }

    for i=1,#excludes do
        excludes[i] = "'" .. excludes[i] .. "'"

        ignores.fd[#ignores.fd + 1] = '--exclude='..excludes[i]
        ignores.find[#ignores.find + 1] = '-iwholename '..excludes[i]
        if i < #excludes then
            ignores.find[#ignores.find + 1] = '-or'
        end
        ignores.ag[#ignores.ag + 1] = ' --ignore '..excludes[i]
        ignores.grep[#ignores.grep + 1] = '--exclude='..excludes[i]

    end

    ignores.find[#ignores.find + 1] = [[\)]]

    -- if is_file(sys.home .. '/.config/git/ignore') then
    --     -- ignores.rg = ' --ignore-file '.. sys.home .. '/.config/git/ignore '
    --     ignores.fd = ' --ignore-file '.. sys.home .. '/.config/git/ignore '
    -- end

    return ignores[tool] ~= nil and table.concat(ignores[tool], ' ') or ''
end

function M.grep(tool, attr, lst)

    local property = (attr and attr ~= '') and  attr or 'grepprg'

    if STORAGE.modern_git == -1 then
        STORAGE.modern_git = M.has_git_version('2', '19')
    end
    local modern_git = STORAGE.modern_git

    local greplist = {
        git = {
            grepprg = 'git --no-pager grep '.. (modern_git and '--column' or '') ..' --no-color -Iin ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
        rg = {
            grepprg = 'rg -SHn --trim --color=never --no-heading --column '..M.ignores('rg')..' ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
        },
        ag = {
            grepprg = 'ag -S --follow --nogroup --nocolor --hidden --vimgrep '..M.ignores('ag')..' ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
        },
        grep = {
            grepprg = 'grep -RHiIn --color=never '..M.ignores('grep')..' ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
        },
        findstr = {
            grepprg = 'findstr -rspn ',
            grepformat = '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
        },
    }

    local grep = lst and {} or ''
    if executable(tool) and greplist[tool] ~= nil then
        grep = greplist[tool][property]
        grep = lst and split(grep, ' ') or grep
    end

    return grep
end

function M.filelist(tool, lst)
    local filetool = {
        git    = 'git --no-pager ls-files -co --exclude-standard',
        fd     = 'fd ' .. M.ignores('fd') .. ' --type=file --hidden --follow --color=never . .',
        rg     = 'rg --color=never --no-search-zip --hidden --trim --files '.. M.ignores('rg'),
        ag     = 'ag -l --follow --nocolor --nogroup --hidden '..M.ignores('ag')..'-g ""',
        find   = "find . -type f -iname '*' "..M.ignores('find') .. ' ',
    }

    filetool.fdfind = string.gsub(filetool.fd, '^fd', 'fdfind')

    local filelist = lst and {} or ''
    if executable(tool) and filetool[tool] ~= nil then
        filelist = filetool[tool]
    elseif tool == 'fd' and not executable('fd') and executable('fdfind') then
        filelist = filetool.fdfind
    end

    if #filelist > 0 then
        filelist = lst and split(filelist, ' ') or filelist
    end
    return filelist
end

function M.select_filelist(is_git, lst)
    local filelist = ''

    local utils = {
        'fd',
        'rg',
        'ag',
        'find',
    }

    if executable('git') and is_git then
        filelist = M.filelist('git', lst)
    else
        for _,lister in pairs(utils) do
            filelist = M.filelist(lister, lst)
            if #filelist > 0 then
                break
            end
        end
    end

    return filelist
end

function M.select_grep(is_git, attr, lst)
    local property = (attr and attr ~= '') and  attr or 'grepprg'

    local grepprg = ''

    local utils = {
        'rg',
        'ag',
        'grep',
        'findstr',
    }

    if executable('git') and is_git then
        grepprg = M.grep('git', property, lst)
    else
        for _,grep in pairs(utils) do
            grepprg = M.grep(grep, property, lst)
            if #grepprg > 0 then
                break
            end
        end
    end

    return grepprg
end

function M.set_grep(is_git, is_local)
    if is_local then
        vim.bo.grepprg = M.select_grep(is_git)
    else
        vim.o.grepprg = M.select_grep(is_git)
    end
    vim.o.grepformat = M.select_grep(is_git, 'grepformat')
end

function M.spelllangs(lang)
    M.abolish(lang)
    vim.wo.spelllang = lang
    print(vim.wo.spelllang)
end

function M.get_abbrs(language)
    return abolish[language]
end

function M.abolish(language)

    local current = vim.bo.spelllang

    if nvim.has.cmd('Abolish') == 2 then
        if abolish[current] ~= nil then
            for base,_ in pairs(abolish[current]) do
                vim.cmd('Abolish -delete -buffer '..base)
            end
        end
        if abolish[language] ~= nil then
            for base,replace in pairs(abolish[language]) do
                vim.cmd('Abolish -buffer '..base..' '..replace)
            end
        end
    else
        local function remove_abbr(base)
            set_abbr{
                mode = 'i',
                lhs = base,
                args = {silent = true, buffer = true},
            }

            set_abbr{
                mode = 'i',
                lhs = base:upper(),
                args = {silent = true, buffer = true},
            }

            set_abbr{
                mode = 'i',
                lhs = base:gsub('%a',  string.upper, 1),
                args = {silent = true, buffer = true}
            }

        end

        local function change_abbr(base, replace)
            set_abbr{
                mode = 'i',
                lhs = base,
                rhs = replace,
                args = {buffer = true},
            }

            set_abbr{
                mode = 'i',
                lhs = base:upper(),
                rhs = replace:upper(),
                args = {buffer = true},
            }

            set_abbr{
                mode = 'i',
                lhs = base:gsub('%a', string.upper, 1),
                rhs = replace:gsub('%a', string.upper, 1),
                args = {buffer = true},
            }
        end

        if abolish[current] ~= nil then
            for base, _ in pairs(abolish[current]) do
                if not string.match(base, '{.+}') then
                    remove_abbr(base)
                end
            end
        end
        if abolish[language] ~= nil then
            for base,replace in pairs(abolish[language]) do
                if not string.match(base, '{.+}') then
                    change_abbr(base, replace)
                end
            end
        end
    end

end

local function check_lsp(servers)
    for _, server in pairs(servers) do
        if executable(server) or is_dir(sys.cache..'/lspconfig/'..server) then
            return true
        end
    end

    return false
end

function M.check_language_server(languages)

    if languages == nil or #languages == 0 then
        for _, server in pairs(langservers) do
            if check_lsp(server) then
                return true
            end
        end
    elseif type(languages) == 'table' then
        for _, language in pairs(languages) do
            if check_lsp(langservers[language]) then
                return true
            end
        end
    elseif langservers[languages] ~= nil then
        return check_lsp(langservers[languages])
    end

    return false
end

function M.get_language_server(language)

    if not M.check_language_server(language) then
        return {}
    end

    local cmds = {
        ['pyls']   = {
            'pyls',
            '--check-parent-process',
            '--log-file=' .. sys.tmp('pyls.log'),
        },
        ['jedi-language-server']   = { 'jedi-language-server' },
        ['clangd'] = {
            'clangd',
            '--index',
            '--background-index',
            '--suggest-missing-includes',
            '--clang-tidy',
            '--header-insertion=iwyu',
            '--function-arg-placeholders',
            '--completion-style=detailed',
            '--log=verbose',
        },
        ['ccls']   = {
            'ccls',
            '--log-file=' .. sys.tmp('ccls.log'),
            '--init={'..
                '"cache": {"directory": "' .. sys.cache .. '/ccls"},'..
                '"completion": {"filterAndSort": false},'..
                '"highlight": {"lsRanges" : true }'..
            '}'
        },
        ['cquery'] = {
            'cquery',
            '--log-file=' .. sys.tmp('cquery.log'),
            '--init={'..
                '"cache": {"directory": "' .. sys.cache .. '/cquery"},'..
                '"completion": {"filterAndSort": false},'..
                '"highlight": { "enabled" : true },'..
                '"emitInactiveRegions" : true'..
            '}'
        },
        ['gopls']  = {'gopls' },
        ['texlab'] = {'texlab' },
        ['bash-language-server'] = {'bash-language-server', 'start'},
        ['vim-language-server']  = {'vim-language-server', '--stdio'},
        ['docker-langserver']    = {'docker-langserver', '--stdio'},
        ['sumneko_lua']    = {
            sys.cache..'/lspconfig/sumneko_lua/lua-language-server/bin/Linux/lua-language-server',
            '-E',
            sys.cache..'/lspconfig/sumneko_lua/lua-language-server/main.lua',
        },
    }

    local cmd = {}

    if langservers[language] ~= nil then
        for _,server in pairs(langservers[language]) do
            if cmds[server] ~= nil then
                cmd = cmds[server]
                break
            end
        end
    end

    return cmd
end

function M.python(version, args)
    local py2 = vim.g.python_host_prog
    local py3 = vim.g.python3_host_prog

    local pyversion = version == 3 and py3 or py2

    if pyversion == nil or pyversion == '' then
        echoerr('Python'..pyversion..' is not available in the system')
        return -1
    end

    local split_type = vim.o.splitbelow and 'botright' or 'topleft'
    vim.cmd(split_type..' split term://'..pyversion..' '..args)
end

function M.toggle_qf(qf_type)
    local action = 'open'

    local qf = qf_funcs[qf_type]

    local qf_winid

    if qf_type == 'qf' then
        qf_winid = vim.fn.getqflist({winid = 0}).winid
    else
        qf_winid = vim.fn.getloclist(0, {winid = 0}).winid
    end

    if qf_winid > 0 then
        for _, winid in pairs(nvim.tab.list_wins(0)) do
            if winid == qf_winid then
                action = 'close'
                break
            end
        end
    end

    nvim.ex[qf[action]]()
end

function M.dump_to_qf(opts)

    if opts.lines then
        opts.context = opts.context or 'GenericQfData'
        opts.title = opts.title or 'Generic Qf data'

        if not opts.efm then
            local ok, val = pcall(nvim.buf.get_option, 0, 'efm')
            opts.efm = ok and val or vim.o.efm
        end

        local qf_cmds = opts.loc and qf_funcs['loc'] or qf_funcs['qf']
        local qf_type = opts.loc and 'loc' or 'qf'

        local qf_open = opts.open or false
        local qf_jump = opts.jump or false

        opts.loc = nil
        opts.open = nil
        opts.jump = nil
        opts.cmdname = nil
        opts.lines = clear_lst(opts.lines)

        if qf_type == 'qf' then
            qf_cmds.set_list({}, 'r', opts)
        else
            local win = opts.win or 0
            opts.win = nil
            qf_cmds.set_list(win, {}, 'r', opts)
        end

        local info_tab = opts.tab

        if info_tab and info_tab ~= nvim.get_current_tabpage() then
            echowarn(('%s Updated! with %s info'):format(
                qf_type == 'qf' and 'Qf' or 'Loc',
                opts.context
            ))
            return
        elseif #opts.lines > 0 then
            if qf_open then
                local qf = (vim.o.splitbelow and 'botright' or 'topleft')..' '..qf_cmds.open
                vim.cmd(qf)
            end

            if qf_jump then
                vim.cmd(qf_cmds.first)
            end
        end
    end
end

function M.clear_qf(buf)
    if buf then
        vim.fn.setloclist(buf, {}, 'r')
        nvim.ex.lclose()
    else
        vim.fn.setqflist({}, 'r')
        nvim.ex.cclose()
    end
end

return M
