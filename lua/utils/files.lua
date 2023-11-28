local nvim = require 'nvim'
local uv = vim.loop

local M = {
    getcwd = uv.cwd,
}

local is_windows = jit.os == 'Windows'

-- TODO: Replace some of these functions with vim.fs conterparts

function M.forward_path(path)
    if is_windows then
        if vim.o.shellslash then
            path = path:gsub('\\', '/')
            return path
        end
        path = path:gsub('/', '\\')
        return path
    end
    return path
end

function M.separator()
    if is_windows and not vim.o.shellslash then
        return '\\'
    end
    return '/'
end

local function join_paths(...)
    return (table.concat({ ... }, '/'):gsub('//+', '/'))
end

function M.normalize(path)
    vim.validate { path = { path, 'string' } }
    assert(path ~= '', debug.traceback 'Empty path')
    if path == '%' then
        local cwd = ((uv.cwd() .. '/'):gsub('\\', '/'):gsub('/+', '/'))
        path = (vim.api.nvim_buf_get_name(0):gsub(vim.pesc(cwd), ''))
    end
    return vim.fs.normalize(path)
end

function M.exists(filename)
    vim.validate { filename = { filename, 'string' } }
    if filename == '' then
        return false
    end
    local stat = uv.fs_stat(M.normalize(filename))
    return stat and stat.type or false
end

function M.is_dir(filename)
    return M.exists(filename) == 'directory'
end

function M.is_file(filename)
    return M.exists(filename) == 'file'
end

function M.mkdir(dirname, recurive)
    vim.validate {
        dirname = { dirname, 'string' },
        recurive = { recurive, 'boolean', true },
    }
    assert(dirname ~= '', debug.traceback 'Empty dirname')
    if M.is_dir(dirname) then
        return true
    end
    dirname = M.normalize(dirname)
    local ok, msg, err = uv.fs_mkdir(dirname, 511)
    if err == 'ENOENT' and recurive then
        local dirs = vim.split(dirname, M.separator() .. '+')
        local base = dirs[1] == '' and '/' or dirs[1]
        if dirs[1] == '' or M.is_root(dirs[1]) then
            table.remove(dirs, 1)
        end
        for _, dir in ipairs(dirs) do
            base = base .. M.separator() .. dir
            if not M.exists(base) then
                ok, msg, _ = uv.fs_mkdir(base, 511)
                if not ok then
                    vim.notify(msg, 'ERROR', { title = 'Mkdir' })
                    break
                end
            else
                ok = M.is_dir(base)
                if not ok then
                    break
                end
            end
        end
    elseif not ok then
        vim.notify(msg, 'ERROR', { title = 'Mkdir' })
    end
    return ok or false
end

function M.link(src, dest, sym, force)
    vim.validate {
        source = { src, 'string' },
        destination = { dest, 'string' },
        use_symbolic = { sym, 'boolean', true },
        force = { force, 'boolean', true },
    }
    assert(src ~= '', debug.traceback 'Empty source')
    assert(dest ~= '', debug.traceback 'Empty destination')
    assert(M.exists(src), debug.traceback('link source ' .. src .. ' does not exists'))

    if dest == '.' then
        dest = vim.fs.basename(src)
    end

    dest = M.normalize(dest)
    src = M.normalize(src)

    assert(src ~= dest, debug.traceback 'Cannot link src to itself')

    local status, msg, _

    if not sym and M.is_dir(src) then
        vim.notify('Cannot hard link a directory', 'ERROR', { title = 'Link' })
        return false
    end

    if not force and M.exists(dest) then
        vim.notify('Dest already exists in ' .. dest, 'ERROR', { title = 'Link' })
        return false
    elseif force and M.exists(dest) then
        status, msg, _ = uv.fs_unlink(dest)
        if not status then
            vim.notify(msg, 'ERROR', { title = 'Link' })
            return false
        end
    end

    if sym then
        status, msg = uv.fs_symlink(src, dest, 438)
    else
        status, msg = uv.fs_link(src, dest)
    end

    if not status then
        vim.notify(msg, 'ERROR', { title = 'Link' })
    end

    return status or false
end

function M.executable(exec)
    vim.validate { exec = { exec, 'string' } }
    assert(exec ~= '', debug.traceback 'Empty executable string')
    return vim.fn.executable(exec) == 1
end

function M.exepath(exec)
    vim.validate { exec = { exec, 'string' } }
    assert(exec ~= '', debug.traceback 'Empty executable string')
    local path = vim.fn.exepath(exec)
    return path ~= '' and path or false
end

function M.is_absolute(path)
    vim.validate { path = { path, 'string' } }
    assert(path ~= '', debug.traceback 'Empty path')
    if path:sub(1, 1) == '~' then
        path = path:gsub('~', uv.os_homedir())
    end

    local is_abs = false
    if is_windows and #path >= 2 then
        is_abs = string.match(path:sub(1, 2), '^%w:$') ~= nil
    elseif not is_windows then
        is_abs = path:sub(1, 1) == '/'
    end
    return is_abs
end

function M.is_root(path)
    vim.validate { path = { path, 'string' } }
    assert(path ~= '', debug.traceback 'Empty path')
    local root = false
    if is_windows and #path >= 2 then
        path = M.forward_path(path)
        root = string.match(path, '^%w:' .. M.separator() .. '?$') ~= nil
    elseif not is_windows then
        root = path == '/'
    end
    return root
end

function M.realpath(path)
    vim.validate { path = { path, 'string' } }
    assert(M.exists(path), debug.traceback(([[Path "%s" doesn't exists]]):format(path)))
    return (uv.fs_realpath(M.normalize(path)):gsub('\\', '/'))
end

function M.basename(file)
    vim.validate { file = { file, 'string', true } }
    if file == nil then
        return nil
    end
    if is_windows and file:match '^%w:[\\/]?$' then
        return ''
    end
    return file:match '[/\\]$' and '' or (file:match('[^\\/]*$'):gsub('\\', '/'))
end

function M.extension(path)
    vim.validate { path = { path, 'string' } }
    assert(path ~= '', debug.traceback 'Empty path')
    local extension = ''
    path = M.normalize(path)
    if not M.is_dir(path) then
        local filename = M.basename(path)
        extension = filename:match '^.+(%..+)$' or ''
    end
    return #extension >= 2 and extension:sub(2, #extension) or extension
end

function M.filename(path)
    vim.validate { path = { path, 'string' } }
    local name = vim.fs.basename(path)
    local extension = M.extension(name)
    return extension ~= '' and (name:gsub('%.' .. extension .. '$', '')) or name
end

function M.dirname(file)
    vim.validate { file = { file, 'string', true } }
    if file == nil then
        return nil
    end
    if is_windows and file:match '^%w:[\\/]?$' then
        return (file:gsub('\\', '/'))
    elseif not file:match '[\\/]' then
        return '.'
    elseif file == '/' or file:match '^/[^/]+$' then
        return '/'
    end
    local dir = file:match '[/\\]$' and file:sub(1, #file - 1) or file:match '^([/\\]?.+)[/\\]'
    if is_windows and dir:match '^%w:$' then
        return dir .. '/'
    end
    return (dir:gsub('\\', '/'))
end

function M.is_parent(parent, child)
    vim.validate { parent = { parent, 'string' }, child = { child, 'string' } }
    assert(M.is_dir(parent), debug.traceback(('Parent path is not a directory "%s"'):format(parent)))
    assert(M.is_dir(child), debug.traceback(('Child path is not a directory "%s"'):format(child)))

    child = M.realpath(child)
    parent = M.realpath(parent)

    -- TODO: Check windows multi drive root
    local is_child = false
    if M.is_root(parent) or child:match('^' .. parent) then
        is_child = true
    end

    return is_child
end

function M.openfile(path, flags, callback)
    vim.validate {
        path = { path, 'string' },
        flags = { flags, 'string' },
        callback = { callback, 'function' },
    }
    assert(path ~= '', debug.traceback 'Empty path')

    local fd, msg, _ = uv.fs_open(path, flags, 438)
    if not fd then
        vim.notify(msg, 'ERROR', { title = 'OpenFile' })
        return false
    end
    local ok, rst = pcall(callback, fd)
    assert(uv.fs_close(fd))
    return rst or ok
end

local function fs_write(path, data, append, callback)
    vim.validate {
        path = { path, 'string' },
        data = {
            data,
            function(d)
                return type(d) == type '' or vim.tbl_islist(d)
            end,
            'a string or an array',
        },
        append = { append, 'boolean', true },
        callback = { callback, 'function', true },
    }

    data = type(data) ~= type '' and table.concat(data, '\n') or data
    local flags = append and 'a+' or 'w+'

    if not callback then
        return M.openfile(path, flags, function(fd)
            local stat = uv.fs_fstat(fd)
            local offset = append and stat.size or 0
            local ok, msg, _ = uv.fs_write(fd, data, offset)
            if not ok then
                vim.notify(msg, 'ERROR', { title = 'Write file' })
            end
        end)
    end

    uv.fs_open(path, 'r+', 438, function(oerr, fd)
        assert(not oerr, oerr)
        uv.fs_fstat(fd, function(serr, stat)
            assert(not serr, serr)
            local offset = append and stat.size or 0
            uv.fs_write(fd, data, offset, function(rerr)
                assert(not rerr, rerr)
                uv.fs_close(fd, function(cerr)
                    assert(not cerr, cerr)
                    return callback()
                end)
            end)
        end)
    end)
end

function M.writefile(path, data, callback)
    return fs_write(path, data, false, callback)
end

function M.updatefile(path, data, callback)
    assert(M.is_file(path), debug.traceback('Not a file: ' .. path))
    return fs_write(path, data, true, callback)
end

function M.readfile(path, split, callback)
    vim.validate {
        path = { path, 'string' },
        callback = { callback, 'function', true },
        split = { split, 'boolean', true },
    }
    assert(M.is_file(path), debug.traceback('Not a file: ' .. path))
    if split == nil then
        split = true
    end
    if not callback then
        return M.openfile(path, 'r', function(fd)
            local stat = assert(uv.fs_fstat(fd))
            local data = assert(uv.fs_read(fd, stat.size, 0))
            if split then
                data = vim.split(data, '[\r]?\n')
                -- NOTE: This seems to always read an extra linefeed so we remove it if it's empty
                if data[#data] == '' then
                    data[#data] = nil
                end
            end
            return data
        end)
    end
    uv.fs_open(path, 'r', 438, function(oerr, fd)
        assert(not oerr, oerr)
        uv.fs_fstat(fd, function(serr, stat)
            assert(not serr, serr)
            uv.fs_read(fd, stat.size, 0, function(rerr, data)
                assert(not rerr, rerr)
                uv.fs_close(fd, function(cerr)
                    assert(not cerr, cerr)
                    if split then
                        data = vim.split(data, '[\r]?\n')
                        if data[#data] == '' then
                            data[#data] = nil
                        end
                    end
                    return callback(data)
                end)
            end)
        end)
    end)
end

function M.chmod(path, mode, base)
    if is_windows then
        return
    end

    vim.validate {
        path = { path, 'string' },
        mode = {
            mode,
            function(m)
                local isnumber = type(m) == type(1)
                -- TODO: check for hex and bin ?
                local isrepr = type(m) == type '' and m ~= ''
                return isnumber or isrepr
            end,
            'valid integer representation',
        },
    }
    assert(path ~= '', debug.traceback 'Empty path')
    base = base == nil and 8 or base
    local ok, msg, _ = uv.fs_chmod(path, tonumber(mode, base))
    if not ok then
        vim.notify(msg, 'ERROR', { title = 'Chmod' })
    end
    return ok or false
end

function M.ls(path, opts)
    vim.validate {
        path = { path, 'string' },
        opts = { opts, 'table', true },
    }
    opts = opts or {}

    local dir_it = uv.fs_scandir(path)
    local filename, ftype
    local results = {}

    repeat
        filename, ftype = uv.fs_scandir_next(dir_it)
        if filename and (not opts.type or opts.type == ftype) then
            table.insert(results, path .. M.separator() .. filename)
        end
    until not filename

    return results
end

function M.get_files(path)
    return M.ls(path, { type = 'file' })
end

function M.get_dirs(path)
    return M.ls(path, { type = 'directory' })
end

function M.copy(src, dest, bang)
    src = M.normalize(src)
    dest = M.normalize(dest)
    dest = M.is_dir(dest) and dest .. '/' .. vim.fs.basename(src) or dest

    if not M.is_dir(src) and (not M.exists(dest) or bang) then
        if M.exists(dest) and bang then
            if not M.delete(dest, bang) then
                return false
            end
        end
        local status, msg = uv.fs_copyfile(src, dest)
        if status then
            return true
        end
        vim.notify('Failed to copy ' .. src .. ' to ' .. dest .. '\n' .. msg, 'ERROR', { title = 'Copy' })
    elseif M.is_dir(src) then
        vim.notify('Cannot recursively copy directories', 'ERROR', { title = 'Copy' })
    else
        vim.notify(dest .. ' exists, use force to override it', 'ERROR', { title = 'Copy' })
    end

    return false
end

function M.rename(old, new, bang)
    local bufloaded = require('utils.buffers').bufloaded
    new = M.normalize(new)
    old = M.normalize(old)
    local load_buffer = bufloaded(old)

    if not M.exists(new) or bang then
        local cursor_pos

        if not M.exists(old) and bufloaded(old) then
            vim.cmd.write(old)
            if M.realpath(nvim.buf.get_name(nvim.get_current_buf())) == M.realpath(old) then
                cursor_pos = nvim.win.get_cursor(nvim.get_current_buf())
            end
        end

        if bufloaded(new) then
            vim.cmd.bwipeout { args = { new }, bang = true }
        end

        local git = RELOAD 'utils.git'

        if
            git.is_git_repo(vim.fs.dirname(old))
            and not vim.list_contains(vim.tbl_map(M.realpath, git.status().untracked or {}), old)
        then
            local result = git.exec.mv { '-f', old, new }
            if #result > 0 then
                vim.notify('Failed to rename ' .. old .. '\n' .. result, 'ERROR', { title = 'Rename' })
                return false
            end
        else
            if not uv.fs_rename(old, new) then
                vim.notify('Failed to rename ' .. old, 'ERROR', { title = 'Rename' })
                return false
            end
        end

        if load_buffer and M.is_file(new) then
            vim.cmd.edit(new)
            if cursor_pos then
                nvim.win.set_cursor(0, cursor_pos)
            end
        end

        if bufloaded(old) then
            vim.cmd.bwipeout { args = { old }, bang = true }
        end
        return true
    elseif M.exists(new) then
        vim.notify(new .. ' exists, use force to override it', 'ERROR', { title = 'Rename' })
    end

    return false
end

function M.delete(target, bang)
    vim.validate {
        target = { target, 'string' },
        bang = { bang, 'boolean', true },
    }

    local bufloaded = require('utils.buffers').bufloaded

    if bang == nil then
        bang = false
    end

    target = M.normalize(target)

    if #target > 1 and target:sub(#target, #target) == '/' then
        target = target:sub(1, #target - 1)
    end

    if M.is_dir(target) then
        if target == uv.os_homedir() then
            vim.notify('Cannot delete home directory', 'ERROR', { title = 'Delete File/Directory' })
            return false
        elseif M.is_root(target) then
            vim.notify('Cannot delete root directory', 'ERROR', { title = 'Delete File/Directory' })
            return false
        elseif target == '.' then
            vim.notify('Cannot delete cwd or parent directory', 'ERROR', { title = 'Delete File/Directory' })
            return false
        end
    end

    local git = RELOAD 'utils.git'
    if M.is_file(target) or bufloaded(target) then
        if
            git.is_git_repo(vim.fs.dirname(target))
            and not vim.list_contains(vim.tbl_map(M.realpath, git.status().untracked or {}), target)
        then
            local result = git.exec.rm { '-f', target }
            if #result > 0 then
                vim.notify('Failed to delete the file ' .. target .. '\n' .. result, 'ERROR', { title = 'Delete' })
                return false
            end
        elseif M.is_file(target) then
            if not uv.fs_unlink(target) then
                vim.notify('Failed to delete the file: ' .. target, 'ERROR', { title = 'Delete' })
                return false
            end
        end
        if bufloaded(target) then
            local command = bang and 'wipeout' or 'delete'
            local ok, error_code = pcall(vim.cmd, { cmd = 'b' .. command, bang = true, args = { target } })
            if not ok and error_code:match 'Vim(.%w+.)\\?:E94' then
                vim.notify('Failed to ' .. command .. ' buffer ' .. target, 'ERROR', { title = 'Delete' })
                return false
            end
        end
        return true
    elseif M.is_dir(target) then
        if
            git.is_git_repo(target)
            and not vim.list_contains(vim.tbl_map(M.realpath, git.status().untracked or {}), target)
        then
            local result = git.exec.rm { bang and '-rf' or '-r', target }
            if #result > 0 then
                vim.notify(
                    'Failed to remove the directory: ' .. target .. '\n' .. result,
                    'ERROR',
                    { title = 'Delete' }
                )
                return false
            end
        elseif vim.fn.delete(target, bang and 'rf' or 'd') == -1 then
            vim.notify('Failed to remove the directory: ' .. target, 'ERROR', { title = 'Delete' })
            return false
        end
        return true
    end

    vim.notify('Non removable target: ' .. target, 'ERROR', { title = 'Delete' })
    return false
end

function M.skeleton_filename(opts)
    if type(opts) ~= 'table' then
        opts = { opts }
    end

    local buf = vim.api.nvim_buf_get_name(0)
    if buf == '' or M.is_file(buf) then
        return
    end

    local buf_lines = nvim.buf.line_count(0)
    if buf_lines > 1 or (buf_lines == 1 and nvim.buf.get_lines(0, 0, 1, true)[1] ~= '') then
        return
    end

    local skeleton
    local filename = vim.fs.basename '%'
    local extension = M.extension '%'
    local skeletons_path = require('sys').base .. '/skeletons/'
    local template = #opts > 0 and opts[1] or ''

    if extension == '' then
        extension = '*'
    else
        filename = filename:gsub('%.' .. extension .. '$', '')
    end

    -- stylua: ignore
    local known_names = {
        ['*'] = { 'clang-format', 'clang-tidy', 'flake8' },
        py    = { 'ycm_extra_conf' },
        json  = { 'projections' },
        c     = { 'main' },
        cpp   = { 'main' },
        go    = { 'main' },
        yaml  = { 'pre-commit-config' },
        toml  = { 'pyproject', 'stylua' },
    }

    if #template ~= 0 then
        skeleton = skeletons_path .. template
    elseif known_names[extension] then
        local names = known_names[extension]

        for _, name in ipairs(names) do
            if filename:match('^%.?' .. (name:gsub('%-', '%%-')) .. '$') then
                local template_file = skeletons_path .. name
                if M.is_file(template_file) then
                    skeleton = template_file
                elseif M.is_file(template_file .. '.' .. extension) then
                    skeleton = template_file .. '.' .. extension
                end
                if skeleton then
                    break
                end
            end
        end
    end

    if not skeleton and extension ~= '' then
        skeleton = skeletons_path .. '/skeleton.' .. extension
    end

    if skeleton and M.is_file(skeleton) then
        local lines = M.readfile(skeleton)
        for i = 1, #lines do
            local line = lines[i]
            if line ~= '' then
                local macro = filename:upper()
                line = line:gsub('%%NAME_H', macro .. '_H')
                line = line:gsub('%%NAME', filename)
                lines[i] = line
            end
        end
        nvim.put(lines, 'c', false, true)
    end
end

function M.trimwhites(buf, range)
    vim.validate {
        buf = { buf, 'number', true },
        range = { range, 'table', true },
    }
    assert(not range or #range == 2, debug.traceback 'range must be {start, end} format')
    range = range or { 0, -1 }
    buf = buf or nvim.get_current_buf()

    local start_line = range[1]
    local end_line = range[2]
    local lines = nvim.buf.get_lines(buf, start_line, end_line, true)

    for i = 1, #lines do
        local line = lines[i]
        if line ~= '' then
            local s_row = (start_line + i) - 1
            local e_row = (start_line + i) - 1

            if line:find '%s+$' then
                local s_col, e_col = line:find '%s+$'
                s_col = s_col - 1
                nvim.buf.set_text(buf, s_row, s_col, e_row, e_col, { '' })
            end
        end
    end
end

function M.clean_file()
    if vim.b.editorconfig and vim.b.editorconfig.trim_trailing_whitespace ~= nil then
        return
    end

    local exc_buftypes = {
        nofile = 1,
        help = 1,
        quickfix = 1,
        terminal = 1,
    }

    local exc_filetypes = {
        bin = 1,
        log = 1,
        git = 1,
        man = 1,
        terminal = 1,
    }

    local buftype = vim.bo.buftype
    local filetype = vim.bo.filetype

    local excluded_buffer = exc_buftypes[buftype] or exc_filetypes[filetype] or filetype == ''
    local clean_buffer = vim.b.trim and not vim.g.disable_trim and not vim.t.disable_trim
    if not clean_buffer or excluded_buffer then
        return false
    end

    local range = { 0, -1 }
    local buf = nvim.get_current_buf()
    M.trimwhites(buf, range)

    local lines = nvim.buf.get_lines(buf, range[1], range[2], true)
    local expandtab = vim.bo.expandtab
    local retab = false
    for i = 1, #lines do
        local line = lines[i]
        if line ~= '' then
            -- NOTE: Retab seems to be faster that set_(text/lines) API
            if (expandtab and line:match '^\t+') or (not expandtab and line:match '^ +') then
                retab = true
                break
            end
        end
    end
    if retab then
        vim.cmd.retab { bang = true }
    end
    return true
end

function M.decode_json(data)
    vim.validate {
        data = { data, { 'string', 'table' } },
    }
    if type(data) == type {} then
        data = table.concat(data, '\n')
    end
    return vim.json.decode(data)
end

function M.encode_json(data)
    vim.validate {
        data = { data, 'table' },
    }
    local json = vim.json.encode(data)
    -- NOTE: Remove this once json:new works and expose the internals of cjson
    return (json:gsub('\\/', '/'))
end

function M.read_json(filename)
    vim.validate {
        filename = { filename, 'string' },
    }
    assert(filename ~= '', debug.traceback 'Empty filename')
    if filename:sub(1, 1) == '~' then
        filename = filename:gsub('~', uv.os_homedir())
    end
    assert(M.is_file(filename), debug.traceback('Not a file: ' .. filename))
    return M.decode_json(M.readfile(filename, false))
end

function M.dump_json(filename, data)
    vim.validate { filename = { filename, 'string' }, data = { data, 'table' } }
    assert(filename ~= '', debug.traceback 'Empty filename')
    if filename:sub(1, 1) == '~' then
        filename = filename:gsub('~', uv.os_homedir())
    end
    return M.writefile(filename, M.encode_json(data))
end

-- NOTE: dir/parents where took from neovim fs.lua source code
function M.dir(path, opts)
    opts = opts or {}

    vim.validate {
        path = { path, { 'string' } },
        depth = { opts.depth, { 'number' }, true },
        skip = { opts.skip, { 'function' }, true },
    }

    if not opts.depth or opts.depth == 1 then
        return coroutine.wrap(function()
            do
                local fs = vim.loop.fs_scandir(vim.fs.normalize(path))
                while true do
                    local name, t = vim.loop.fs_scandir_next(fs)
                    if name == nil then
                        break
                    end
                    coroutine.yield(name, t)
                end
            end
        end)
    end

    --- @async
    return coroutine.wrap(function()
        local dirs = { { path, 1 } }
        while #dirs > 0 do
            local dir0, level = unpack(table.remove(dirs, 1))
            local dir = level == 1 and dir0 or join_paths(path, dir0)
            local fs = vim.loop.fs_scandir(vim.fs.normalize(dir))
            while fs do
                local name, t = vim.loop.fs_scandir_next(fs)
                if not name then
                    break
                end
                local f = level == 1 and name or join_paths(dir0, name)
                coroutine.yield(f, t)
                if
                    opts.depth
                    and level < opts.depth
                    and t == 'directory'
                    and (not opts.skip or opts.skip(f) ~= false)
                then
                    dirs[#dirs + 1] = { f, level + 1 }
                end
            end
        end
    end)
end

function M.parents(dir)
    vim.validate { dir = { dir, 'string' } }
    dir = M.realpath(dir)
    return coroutine.wrap(function()
        local parent = M.dirname(dir)
        while parent ~= dir do
            coroutine.yield(parent)
            dir = parent
            parent = M.dirname(dir)
        end
    end)
end

function M.find(filename, opts)
    vim.validate {
        filename = { filename, { 'function', 'string', 'table' } },
        opts = { opts, 'table', true },
    }

    if nvim.has { 0, 8 } then
        return vim.fs.find(filename, opts)
    end
    -- TODO: Implement this for neovim < 0.8
    error(debug.traceback 'Not implemented yet')
end

function M.is_executable(filename)
    vim.validate {
        filename = { filename, 'string' },
    }
    return vim.loop.fs_access(vim.fs.normalize(filename), 'X')
end

function M.chmod_exec(buf)
    vim.validate {
        buf = { buf, 'number', true },
    }
    local filename = vim.api.nvim_buf_get_name(buf or 0)
    if not M.is_executable(filename) then
        local fileinfo = vim.loop.fs_stat(filename)
        local filemode = fileinfo.mode - 32768
        M.chmod(filename, bit.bor(filemode, 0x48), 10)
    end
end

function M.make_executable()
    local sys = require 'sys'
    if sys.name == 'windows' then
        return
    end

    local filename = vim.api.nvim_buf_get_name(0)
    if M.is_executable(filename) then
        return
    end

    local shebang = nvim.buf.get_lines(0, 0, 1, true)[1]
    if not shebang or not shebang:match '^#!.+' then
        nvim.autocmd.add('BufWritePre', {
            group = 'MakeExecutable',
            buffer = nvim.win.get_buf(0),
            callback = function()
                M.make_executable()
            end,
            once = true,
        })
        return
    end

    if not M.is_executable(filename) or not M.exists(filename) then
        -- TODO: Add support to pass buffer
        nvim.autocmd.add('BufWritePost', {
            group = 'MakeExecutable',
            buffer = nvim.win.get_buf(0),
            callback = function()
                M.chmod_exec()
            end,
            once = true,
        })
    end
end

function M.find_in_dir(args)
    args = args or {}
    vim.validate {
        pattern = { args.pattern, { 'function', 'table', 'string' } },
        dir = { args.dir, 'string', true },
        callback = { args.callback, 'function', true },
    }

    local dir
    if args.dir and args.dir ~= '' then
        dir = M.realpath(args.dir)
    else
        dir = vim.api.nvim_buf_get_name(0)
    end

    local cwd = vim.loop.cwd()
    if dir ~= cwd then
        dir = dir:gsub(vim.pesc(cwd) .. '/', ''):gsub('/.*', '')
    end

    local pattern = args.pattern
    local filter
    if type(pattern) == 'function' then
        filter = pattern
        pattern = nil
    end

    if args.callback then
        RELOAD('threads.functions').async_find {
            target = pattern,
            filter = filter,
            opts = {
                type = 'file',
                path = dir,
            },
            cb = args.callback,
        }
        return
    end
    local results = RELOAD('threads.functions').find {
        args = {
            target = pattern,
            opts = {
                type = 'file',
                path = dir,
            },
        },
        functions = {
            filter = filter,
        },
    }
    return results
end

return M
