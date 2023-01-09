local nvim = require 'neovim'

local M = {}

function M.last_position()
    local sc_mark = nvim.buf.get_mark(0, "'")
    local dc_mark = nvim.buf.get_mark(0, '"')
    local last_line = nvim.fn.line '$'
    local filetype = nvim.bo.filetype

    local black_list = {
        git = 1,
        gitcommit = 1,
        fugitive = 1,
        qf = 1,
    }

    if sc_mark[1] >= 1 and dc_mark[1] <= last_line and not black_list[filetype] then
        nvim.win.set_cursor(0, dc_mark)
    end
end

function M.bufloaded(buffer)
    vim.validate {
        buffer = {
            buffer,
            function(b)
                return type(b) == type '' or type(b) == type(1)
            end,
            'filepath string or a buffer number',
        },
    }
    -- return vim.api.nvim_buf_is_loaded(bufnr)
    return vim.fn.bufloaded(buffer) == 1
end

function M.is_modified(bufnr)
    vim.validate { buffer = { bufnr, 'number', true } }

    bufnr = bufnr or nvim.get_current_buf()
    return vim.bo[bufnr].modified
end

function M.delete(bufnr, wipe)
    vim.validate { buffer = { bufnr, 'number', true }, wipe = { wipe, 'boolean', true } }
    assert(not bufnr or bufnr > 0, debug.traceback 'Buffer must be greater than 0')

    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local is_duplicated = false
    local is_wipe = vim.bo[bufnr].bufhidden == 'wipe'
    local prev_buf = vim.fn.expand '#' ~= '' and vim.fn.bufnr(vim.fn.expand '#') or -1
    prev_buf = prev_buf == bufnr and -1 or prev_buf

    if prev_buf == -1 then
        local wins = nvim.tab.list_wins(0)
        if #wins > 1 then
            local current_win = nvim.get_current_win()
            for _, win in pairs(wins) do
                local buf = nvim.win.get_buf(win)
                if win ~= current_win and buf ~= bufnr then
                    prev_buf = buf
                    break
                end
            end
        end
        local bufs = nvim.list_bufs()
        if #bufs > 1 and prev_buf == -1 then
            for _, buf in pairs(bufs) do
                if nvim.buf.is_loaded(buf) and buf ~= bufnr then
                    prev_buf = buf
                    break
                end
            end
        end
    end

    -- TODO: Don't create multiple empty buffers just do nothing here if buf == [No Name]
    if nvim.get_current_buf() == bufnr then
        local new_view = nvim.buf.is_loaded(prev_buf) and prev_buf or nvim.create_buf(true, false)
        nvim.win.set_buf(0, new_view)
    end

    for _, tab in pairs(nvim.list_tabpages()) do
        for _, win in pairs(nvim.tab.list_wins(tab)) do
            if nvim.win.get_buf(win) == bufnr then
                is_duplicated = true
                break
            end
        end
    end

    if not is_duplicated and not is_wipe and nvim.buf.is_valid(bufnr) then
        local action = { unload = true }
        -- TODO: maybe should ask for confirmation in non scratch modified buffers
        if wipe or vim.bo[bufnr].modified then
            action = { force = true }
        end
        nvim.buf.delete(bufnr, action)
    end
end

function M.get_option(option, default)
    local ok, opt = pcall(nvim.buf.get_option, 0, option)
    if not ok then
        ok, opt = pcall(nvim.get_option, 0, option)
        if not ok then
            opt = default
        end
    end
    return opt
end

function M.get_indent()
    local indent = vim.opt_local.softtabstop:get()
    if indent <= 0 then
        indent = vim.opt_local.shiftwidth:get()
        if indent == 0 then
            indent = vim.opt_local.tabstop:get()
        end
    end
    return indent
end

function M.get_indent_block(lines)
    vim.validate { lines = { lines, 'table' } }
    assert(vim.tbl_islist(lines), debug.traceback 'Lines must be an array')

    local indent_level
    for _, line in pairs(lines) do
        if #line > 0 then
            local level = line:match '^%s+'
            level = level and #level or nil
            if not level then
                indent_level = 0
                break
            elseif not indent_level or level < indent_level then
                indent_level = level
            end
        end
    end
    return indent_level or 0
end

function M.get_indent_block_level(lines)
    vim.validate { lines = { lines, 'table' } }
    assert(vim.tbl_islist(lines), debug.traceback 'Lines must be an array')

    local indent_level = M.get_indent_block(lines)
    return math.floor(indent_level / M.get_indent())
end

function M.get_indent_string(indent)
    vim.validate { indent = { indent, 'number', true } }

    local expand = vim.opt_local.expandtab:get()
    indent = indent or M.get_indent()
    local spaces = not expand and '\t' or string.rep(' ', indent)
    return spaces
end

local function normalize_indent(lines, indent)
    local expand = vim.opt_local.expandtab:get()
    local spaces = M.get_indent_string(indent)

    for i = 1, #lines do
        if #lines[i] > 0 and not lines[i]:match '^%s+$' then
            if expand then
                lines[i] = lines[i]:gsub('\t', spaces)
            else
                lines[i] = lines[i]:gsub(spaces, '\t')
            end
        end
    end

    return lines
end

function M.indent(lines, level)
    vim.validate { lines = { lines, 'table' }, level = { level, 'number' } }
    assert(vim.tbl_islist(lines), debug.traceback 'Lines must be an array')

    if level == 0 or #lines == 0 then
        return lines
    end

    local abslevel = math.abs(level)

    local indent = M.get_indent()
    local expand = vim.opt_local.expandtab:get()
    local tmp_lines = vim.deepcopy(lines)

    tmp_lines = normalize_indent(tmp_lines, abslevel)

    local spaces = not expand and string.rep('\t', abslevel) or string.rep(' ', indent * abslevel)

    if level < 0 then
        local block_indent = M.get_indent_block(tmp_lines)
        if block_indent == 0 then
            return tmp_lines
        else
            if not expand then
                block_indent = block_indent * indent
            end

            if block_indent < abslevel * indent then
                return tmp_lines
            end
        end
        spaces = '^' .. spaces
    end

    for i = 1, #tmp_lines do
        if #tmp_lines[i] > 0 and not tmp_lines[i]:match '^%s+$' then
            if level < 0 then
                tmp_lines[i] = tmp_lines[i]:gsub(spaces, '')
            else
                tmp_lines[i] = spaces .. tmp_lines[i]
            end
        end
    end

    return tmp_lines
end

-- TODO: Make this function async, maybe using readfile
-- TODO: Respect indent format from editorconfig and other files
-- TODO: Cache indent settings using SQLite?
function M.detect_indent(buf)
    vim.validate { buffer = { buf, 'number', true } }

    buf = buf or vim.api.nvim_get_current_buf()

    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end

    if vim.b.editorconfig and (vim.b.editorconfig.indent_size or vim.b.editorconfig.indent_style) then
        return
    end

    local ignore_fts = {
        man = true,
        help = true,
        qf = true,
        Telescope = true,
        TelescopePrompt = true,
        TelescopeResults = true,
    }

    local ft = vim.bo[buf].filetype
    local buftype = vim.bo[buf].buftype
    local ok, indent_set = pcall(vim.api.nvim_buf_get_var, buf, 'indent_set')
    indent_set = ok and indent_set or false

    if ignore_fts[ft] or indent_set or buftype ~= '' then
        return
    end

    -- -- Respect modaline
    -- if vim.api.nvim_buf_get_option(buf, 'modeline') then
    --     local last_line = vim.api.nvim_buf_get_lines(buf, -2, -1, false)[1]
    --     if last_line and last_line:match '^%s*vim:' then
    --         for _, val in ipairs(vim.split(last_line, ':')) do
    --             if val:match 'ts%=%d+' or val:match 'tabstop%=%d+' then
    --                 return
    --             end
    --         end
    --     end
    -- end

    local ts_utils = RELOAD 'utils.treesitter'

    local indent = vim.bo[buf].tabstop
    local expandtab = vim.bo[buf].expandtab
    local is_in_node = ts_utils.is_in_node
    local has_ts = ts_utils.has_ts(buf)

    -- BUG: This hangs neovim's startup, seems to be a race condition, tested in windows 10
    -- local line_count = vim.api.nvim_buf_line_count(buf)

    local line_count = vim.fn.line '$'
    local lines = vim.api.nvim_buf_get_lines(buf, 0, line_count < 1024 and line_count or 1024, true)
    -- TODO: may change this to while to skip ranges of un interested blocks of code

    local blacklist = {
        'string',
        'comment',
        'paragraph',
        'document',
        'parameter_list',
        'field_initializer_list',
        'field_initializer',
        'parameters',
    }

    for idx, line in ipairs(lines) do
        if line and #line > 0 and not line:match '^%s*$' then
            local indent_str = line:match '^(%s+)[^%s]+'
            if indent_str then
                -- Use TS to avoid multiline strings and comments
                -- We may need to fallback to lua pattern matching if TS is not available
                if not has_ts or not is_in_node({ idx - 1, #indent_str - 1, idx - 1, #line - 1 }, blacklist) then
                    -- NOTE: we may need to confirm tab indent with more than 1 line and avoid mix indent
                    if indent_str:match '^\t+$' then
                        expandtab = false
                        break
                    elseif indent_str:match '^ +$' and #indent_str < 9 and #indent_str > 1 then
                        indent = #indent_str
                        expandtab = true
                        break
                    end
                end
            end
        end
    end

    vim.bo[buf].expandtab = expandtab
    vim.bo[buf].tabstop = indent
    vim.bo[buf].softtabstop = -1
    vim.bo[buf].shiftwidth = 0

    -- Cache this indent to avoid re-set it
    vim.b[buf].indent_set = true

    return indent
end

function M.replace_indent(cmd)
    vim.validate { cmd = { cmd, 'table' } }
    for idx, arg in ipairs(cmd) do
        if arg == '$WIDTH' then
            cmd[idx] = M.get_indent()
            break
        end
    end
    return cmd
end

function M.format(opts)
    opts = opts or {}

    local ft = opts.ft or vim.opt_local.filetype:get()
    local buffer = vim.api.nvim_get_current_buf()
    local external_formatprg = require('utils.functions').external_formatprg
    local ok, utils = pcall(require, 'filetypes.' .. ft)

    local view = vim.fn.winsaveview()

    local first = vim.v.lnum - 1
    local last = first + vim.v.count
    local whole_file = last - first == nvim.buf.line_count(0) or opts.whole_file

    local clients = vim.lsp.buf_get_clients(0)

    -- TODO: Null-ls always report formatting capabilities
    for _, client in pairs(clients) do
        if whole_file and client.server_capabilities.documentFormattingProvider then
            -- TODO: May add filter to prefere some lsp over the others
            if nvim.has { 0, 8 } then
                vim.lsp.buf.format { async = false }
            else
                vim.lsp.buf.formatting()
            end
            vim.fn.winrestview(view)
            return 0
        elseif client.server_capabilities.documentRangeFormattingProvider then
            if nvim.has { 0, 8 } then
                vim.lsp.buf.format {
                    async = false,
                    range = {
                        start = { first, 0 },
                        ['end'] = { last, #nvim.buf.get_lines(0, last, last + 1, false)[1] },
                    },
                }
            else
                vim.lsp.buf.range_formatting(
                    nil,
                    { first, 0 },
                    { last, #nvim.buf.get_lines(0, last, last + 1, false)[1] }
                )
            end
            vim.fn.winrestview(view)
            return 0
        end
    end

    if ok and utils.get_formatter then
        local cmd = utils.get_formatter()
        if cmd then
            if opts.whole_file then
                first = 0
                last = -1
            else
                first = nil
                last = nil
            end
            external_formatprg {
                cmd = M.replace_indent(cmd),
                buffer = buffer,
                efm = utils.formatprg[cmd[1]].efm,
                first = first,
                last = last,
            }
            return 0
        end
    end

    return 1
end

function M.setup(ft, opts)
    vim.validate { ft = { ft, 'string', true }, opts = { opts, 'table', true } }

    -- local bufnum = vim.api.nvim_get_current_buf()
    -- local buftype = vim.api.nvim_buf_get_option(bufnum, 'buftype')
    ft = ft or vim.opt_local.filetype:get()

    -- NOTE: C uses C++ setup
    if ft == 'c' then
        ft = 'cpp'
    end

    local ok, utils = pcall(RELOAD, 'filetypes.' .. ft)
    opts = opts or {}
    if ok then
        if utils.get_linter then
            local linter = utils.get_linter()
            if linter then
                table.insert(linter, '%')
                vim.opt_local.makeprg = table.concat(linter, ' ')
                if (utils.makeprg[linter[1]] or utils.makeprg[vim.fs.basename(linter[1])]).efm then
                    vim.opt_local.errorformat = utils.makeprg[linter[1]].efm
                end
            end
            opts.makeprg = nil
            opts.errorformat = nil
        end

        if utils.get_formatter then
            local formatter = utils.get_formatter()
            if formatter and vim.opt_local.formatexpr:get() == '' then
                vim.opt_local.formatexpr = ([[luaeval('require"utils.buffers".format("%s")')]]):format(ft)
            end
            opts.formatexpr = nil
        end

        if utils.setup then
            utils.setup()
        end
    end

    for option, value in pairs(opts) do
        vim.opt_local[option] = value
    end
end

function M.remove_empty(opts)
    local bufs_in_use = {}
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            bufs_in_use[tostring(vim.api.nvim_win_get_buf(win))] = true
        end
    end

    local function buf_is_empty(buf)
        if vim.api.nvim_buf_line_count(buf) == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == '' then
            return true
        end
        return false
    end

    local function buf_is_scratch(buf)
        if vim.api.nvim_buf_get_name(buf) == '' or vim.api.nvim_buf_get_option(buf, 'buftype') == 'nofile' then
            return true
        end
        return false
    end

    local removed = 0
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf_is_empty(buf) and buf_is_scratch(buf) and not bufs_in_use[buf] then
            vim.api.nvim_buf_delete(buf, { force = true })
            removed = removed + 1
        end
    end

    if removed > 0 then
        print(' ', removed, ' Buffers cleaned!')
    end
end

return M
