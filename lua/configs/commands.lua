local sys = require 'sys'
local nvim = require 'nvim'

local executable = require('utils.files').executable
local completions = RELOAD 'completions'

if sys.name ~= 'windows' then
    nvim.command.set('Chmod', function(opts)
        RELOAD('mappings').chmod(opts)
    end, { nargs = 1, desc = 'Change the permission of the current buffer/file' })
end

nvim.command.set('ClearQf', function()
    RELOAD('utils.qf').clear()
end)

nvim.command.set('ClearLoc', function()
    RELOAD('utils.qf').clear(nvim.get_current_win())
end)

nvim.command.set('Terminal', function(opts)
    RELOAD('mappings').floating_terminal(opts)
end, { nargs = '*', desc = 'Show big center floating terminal window' })

nvim.command.set('MouseToggle', function()
    RELOAD('mappings').toggle_mouse()
end, { desc = 'Enable/Disable Mouse support' })

nvim.command.set('BufKill', function(opts)
    opts = opts or {}
    opts.rm_no_cwd = vim.list_contains(opts.fargs, '-cwd')
    opts.rm_empty = vim.list_contains(opts.fargs, '-empty')
    RELOAD('mappings').bufkill(opts)
end, { desc = 'Remove unloaded hidden buffers', bang = true, nargs = '*', complete = completions.bufkill_options })

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
    RELOAD('mappings').trim(opts)
end, {
    desc = 'Enable/Disable auto trim of trailing white spaces',
    nargs = '?',
    complete = completions.toggle,
    bang = true,
})

if executable 'gonvim' then
    nvim.command.set(
        'GonvimSettngs',
        "execute('edit ~/.gonvim/setting.toml')",
        { desc = "Shortcut to edit gonvim's setting.toml" }
    )
end

nvim.command.set('FileType', function(opts)
    vim.opt_local.filetype = opts.args ~= '' and opts.args or 'text'
end, { nargs = '?', complete = 'filetype', desc = 'Set filetype' })

nvim.command.set('FileFormat', function(opts)
    vim.opt_local.filetype = opts.args ~= '' and opts.args or 'unix'
end, { nargs = '?', complete = completions.fileformats, desc = 'Set file format' })

nvim.command.set('SpellLang', function(opts)
    RELOAD('utils.functions').spelllangs(opts.args)
end, { nargs = '?', complete = completions.spells, desc = 'Enable/Disable spelling' })

nvim.command.set('Qopen', function(opts)
    opts.size = tonumber(opts.args)
    if opts.size then
        opts.size = opts.size + 1
    end
    RELOAD('utils.qf').toggle(opts)
end, { nargs = '?', desc = 'Open quickfix' })

nvim.command.set('MoveFile', function(opts)
    RELOAD('mappings').move_file(opts)
end, { bang = true, nargs = 1, complete = 'file', desc = 'Move current file to another location' })

nvim.command.set('RenameFile', function(opts)
    RELOAD('mappings').rename_file(opts)
end, { bang = true, nargs = 1, complete = 'file', desc = 'Rename current file to another location' })

nvim.command.set('Mkdir', function(opts)
    vim.fn.mkdir(vim.fn.fnameescape(opts.args), 'p')
end, { nargs = 1, complete = 'dir', desc = 'mkdir wrapper' })

nvim.command.set('RemoveFile', function(opts)
    local target = opts.args ~= '' and opts.args or vim.api.nvim_buf_get_name(0)
    local utils = RELOAD 'utils.files'
    utils.delete(utils.realpath(target), opts.bang)
end, { bang = true, nargs = '?', complete = 'file', desc = 'Remove current file and close the window' })

nvim.command.set('CopyFile', function(opts)
    local utils = RELOAD 'utils.files'
    local src = vim.api.nvim_buf_get_name(0)
    local dest = opts.fargs[1]
    utils.copy(src, dest, opts.bang)
end, { bang = true, nargs = 1, complete = 'file', desc = 'Copy current file to another location' })

nvim.command.set('Grep', function(opts)
    local search = opts.fargs[#opts.fargs]
    opts.fargs[#opts.fargs] = nil
    local args = opts.fargs
    if #args > 0 then
        local grepprg = vim.tbl_filter(function(k)
            return not k:match '^%s*$'
        end, RELOAD('utils.functions').select_grep(false, nil, true))

        vim.list_extend(args, vim.list_slice(grepprg, 2, #grepprg))
    end
    RELOAD('utils.functions').send_grep_job { search = search, args = args }
end, { nargs = '+', complete = 'file' })

nvim.command.set('LGrep', function(opts)
    local search = opts.fargs[#opts.fargs]
    opts.fargs[#opts.fargs] = nil

    local args = opts.fargs
    if #args > 0 then
        local grepprg = vim.tbl_filter(function(k)
            return not k:match '^%s*$'
        end, RELOAD('utils.functions').select_grep(false, nil, true))

        vim.list_extend(args, vim.list_slice(grepprg, 2, #grepprg))
    end

    RELOAD('utils.functions').send_grep_job { loc = true, search = search, args = args }
end, { nargs = '+', complete = 'file' })

nvim.command.set('Find', function(opts)
    local args = {
        args = opts.fargs,
        target = opts.args,
        cb = function(results)
            if #results > 0 then
                RELOAD('utils.qf').dump_files(results, {
                    open = true,
                    jump = false,
                    title = 'Finder',
                })
            else
                vim.notify('No files matching: ' .. opts.fargs[#opts.fargs], vim.log.levels.ERROR, { title = 'Find' })
            end
        end,
    }
    RELOAD('mappings').find(args)
end, { bang = true, nargs = '+', complete = 'file', desc = 'Async and recursive :find' })

nvim.command.set('LFind', function(opts)
    local args = {
        args = opts.fargs,
        target = opts.args,
        cb = function(results)
            if #results > 0 then
                RELOAD('utils.qf').dump_files(results, {
                    open = true,
                    jump = false,
                    title = 'LFinder',
                }, nvim.get_current_win())
            else
                vim.notify('No files matching: ' .. opts.fargs[#opts.fargs], vim.log.levels.ERROR, { title = 'Find' })
            end
        end,
    }
    RELOAD('mappings').find(args)
end, { bang = true, nargs = '+', complete = 'file', desc = 'Async and recursive :lfind' })

nvim.command.set('Make', function(opts)
    RELOAD('mappings').async_makeprg(opts)
end, { nargs = '*', desc = 'Async execution of current makeprg' })

if executable 'cscope' and not nvim.has { 0, 9 } then
    for query, _ in pairs(require('mappings').cscope_queries) do
        local cmd = 'C' .. query:sub(1, 1):upper() .. query:sub(2, #query)
        nvim.command.set(cmd, function(opts)
            RELOAD('mappings').cscope(opts.args, query)
        end, { nargs = '?', desc = 'cscope command to find ' .. query .. ' under cursor or arg' })
    end
end

if executable 'scp' then
    nvim.command.set('SendFile', function(opts)
        RELOAD('mappings').remote_file(opts.args, true)
    end, {
        nargs = '*',
        complete = completions.ssh_hosts_completion,
        desc = 'Send current file to a remote location',
    })

    nvim.command.set('GetFile', function(opts)
        RELOAD('mappings').remote_file(opts.args, false)
    end, {
        nargs = '*',
        complete = completions.ssh_hosts_completion,
        desc = 'Get current file from a remote location',
    })

    nvim.command.set('SCPEdit', function(opts)
        local args = {
            host = opts.fargs[1],
            filename = opts.fargs[2],
        }
        RELOAD('utils.functions').scp_edit(args)
    end, { nargs = '*', desc = 'Edit remote file using scp', complete = completions.ssh_hosts_completion })
end

nvim.command.set('Scratch', function(opts)
    RELOAD('mappings').scratch_buffer(opts)
end, {
    nargs = '?',
    complete = 'filetype',
    desc = 'Create a scratch buffer of the current or given filetype',
})

nvim.command.set('ConcealLevel', function()
    local conncall = vim.opt_local.conceallevel:get() or 0
    vim.opt_local.conceallevel = conncall > 0 and 0 or 2
end, { desc = 'Toggle conceal level between 0 and 2' })

nvim.command.set('Messages', function(opts)
    RELOAD('mappings').messages(opts)
end, { nargs = '?', complete = 'messages', desc = 'Populate quickfix with the :messages list' })

if executable 'pre-commit' then
    nvim.command.set('PreCommit', function(opts)
        RELOAD('mappings').precommit(opts)
    end, { nargs = '*' })
end

-- TODO: Add support to change between local and osc/remote open
nvim.command.set('Open', function(opts)
    vim.ui.open(opts.args)
end, {
    nargs = 1,
    complete = 'file',
    desc = 'Open file in the default OS external program',
})

nvim.command.set('Repl', function(opts)
    RELOAD('mappings').repl(opts)
end, { nargs = '*', complete = 'filetype' })

-- TODO: May need to add a check for "zoom" executable but this should work even inside WSL
nvim.command.set('Zoom', function(opts)
    RELOAD('mappings').zoom_links(opts)
end, { nargs = 1, complete = completions.zoom_links, desc = 'Open Zoom call in a specific room' })

nvim.command.set('Edit', function(opts)
    RELOAD('mappings').edit(opts)
end, { nargs = '*', complete = 'file', desc = 'Open multiple files' })

nvim.command.set('DiffFiles', function(opts)
    RELOAD('mappings').diff_files(opts)
end, { nargs = '+', complete = 'file', desc = 'Open a new tab in diff mode with the given files' })

-- NOTE: I should not need to create this function, but I couldn't find a way to override
--       internal runtime compilers
nvim.command.set('Compiler', function(opts)
    RELOAD('mappings').custom_compiler(opts)
end, {
    nargs = 1,
    complete = 'compiler',
    desc = 'Set the given compiler with preference on the custom compilers located in the after directory',
})

nvim.command.set('Reloader', function(opts)
    local configs = {
        mappings = 'mappings',
        commands = 'commands',
        autocmds = 'autocmds',
        options = 'options',
    }

    local files = {}

    local lua_file_path = '%s/lua/configs/%s.lua'
    local config_dir = vim.fn.stdpath 'config'
    if opts.args == 'all' or opts.args == '' then
        for _, v in ipairs(configs) do
            table.insert(files, lua_file_path:format(config_dir, v))
        end
    elseif configs[opts.args] then
        table.insert(files, lua_file_path:format(config_dir, opts.args))
    else
        vim.notify('Invalid config name: ' .. opts.args, vim.log.levels.ERROR, { title = 'Reloader' })
        return
    end

    RELOAD('mappings').reload_configs(files)
end, {
    nargs = '?',
    desc = 'Change between git grep and the best available alternative',
    complete = completions.reload_configs,
})

nvim.command.set('AutoFormat', function(opts)
    RELOAD('mappings').autoformat(opts)
end, { nargs = '?', complete = completions.toggle, bang = true, desc = 'Toggle Autoformat autocmd' })

nvim.command.set('Wall', function(opts)
    RELOAD('mappings').wall(opts)
end, { desc = 'Saves all visible windows' })

nvim.command.set('AlternateGrep', function()
    RELOAD('mappings').alternate_grep()
end, { nargs = 0, desc = 'Change between git grep and the best available alternative' })

if executable 'gradle' then
    nvim.command.set('Gradle', function(opts)
        RELOAD('mappings').gradle(opts)
    end, { nargs = '+', desc = 'Execute Gradle async' })
end

-- TODO: Add support for nvim < 0.8
if nvim.has { 0, 8 } then
    nvim.command.set('Alternate', function(opts)
        RELOAD('mappings').alternate(opts)
    end, { nargs = 0, desc = 'Alternate between files', bang = true })

    nvim.command.set('A', function(opts)
        RELOAD('mappings').alternate(opts)
    end, { nargs = 0, desc = 'Alternate between files', bang = true })

    nvim.command.set('AlternateTest', function(opts)
        RELOAD('mappings').alternate_test(opts)
    end, { nargs = 0, desc = 'Alternate between source and test files', bang = true })

    nvim.command.set('T', function(opts)
        RELOAD('mappings').alternate_test(opts)
    end, { nargs = 0, desc = 'Alternate between source and test files', bang = true })

    -- nvim.command.set('AltMakefile', function(opts)
    --     RELOAD('mappings').alt_makefiles(opts)
    -- end, { nargs = 0, desc = 'Open related makefile', bang = true })
end

nvim.command.set('NotificationServer', function(opts)
    opts.enable = opts.args == 'enable' or opts.args == ''
    RELOAD('servers.notifications').start_server(opts)
end, { nargs = 1, complete = completions.toggle, bang = true })

nvim.command.set('RemoveEmpty', function(opts)
    local removed = RELOAD('utils.buffers').remove_empty(opts)
    if removed > 0 then
        print(' ', removed, ' buffers cleaned!')
    end
end, { nargs = 0, bang = true, desc = 'Remove empty buffers' })

nvim.command.set('Qf2Diag', function()
    RELOAD('utils.qf').qf_to_diagnostic()
end)

nvim.command.set('Loc2Diag', function()
    RELOAD('utils.qf').qf_to_diagnostic(nil, true)
end)

nvim.command.set('Diagnostics', function(opts)
    local action = opts.fargs[1]:gsub('^%-+', '')
    local namespaces = vim.list_slice(opts.fargs, 2, #opts.fargs)
    if #namespaces == 0 then
        for _, ns in pairs(vim.diagnostic.get_namespaces()) do
            table.insert(namespaces, ns.name)
        end
    end

    if action == 'dump' then
        local severity = namespaces[1]
        table.remove(namespaces, 1)
        if severity then
            if not vim.log.levels[severity] then
                error(debug.traceback(string.format('Invalid severity: %s', vim.inspect(severity))))
            end
            severity = { min = severity }
        end
        if opts.bang then
            vim.diagnostic.setqflist { severity = severity }
            vim.cmd.wincmd 'J'
        else
            vim.diagnostic.setloclist { severity = severity }
        end
    else
        action = action == 'clear' and 'reset' or action
        if not vim.diagnostic[action] then
            error(debug.traceback(string.format('Invalid diagnostic action: %s', action)))
        end
        for _, ns in ipairs(namespaces) do
            local buf = not opts.bang and vim.api.nvim_get_current_buf() or nil
            local ns_id = RELOAD('utils.buffers').get_diagnostic_ns(ns, buf)
            if ns_id then
                if action == 'enable' or action == 'disable' then
                    vim.diagnostic[action](buf, ns_id)
                else
                    vim.diagnostic[action](ns_id, buf)
                end
            end
        end
    end
end, {
    bang = true,
    nargs = '+',
    desc = 'Manage Diagnostics actions on NS and buffers',
    complete = completions.diagnostics_completion,
})

nvim.command.set('KillJob', function(opts)
    RELOAD('mappings').kill_job(opts)
end, { nargs = '?', bang = true, desc = 'Kill the selected job' })

nvim.command.set('Progress', function(opts)
    RELOAD('mappings').show_job_progress(opts)
end, { nargs = 1, desc = 'Show progress of the selected job', complete = completions.background_jobs })

nvim.command.set('CLevel', function(opts)
    opts.level = opts.args
    RELOAD('utils.qf').filter_qf_diagnostics(opts)
end, {
    nargs = 1,
    bang = true,
    desc = 'Filter the quickfix by diagnostcis level',
    complete = completions.diagnostics_level,
})

nvim.command.set('LLevel', function(opts)
    opts.win = vim.api.nvim_get_current_win()
    opts.level = opts.args
    RELOAD('utils.qf').filter_qf_diagnostics(opts)
end, {
    nargs = 1,
    bang = true,
    desc = 'Filter the location list by diagnostcis level',
    complete = completions.diagnostics_level,
})

if executable 'git' then
    nvim.command.set('OpenChanges', function(opts)
        local action = 'open'
        local revision
        for _, arg in ipairs(opts.fargs) do
            if arg:match '^%-' then
                action = (arg:gsub('^%-+', ''))
            else
                revision = arg
            end
        end

        if opts.bang and (not revision or revision == '') then
            vim.notify(
                'Missing revision, opening changes from latest HEAD',
                vim.log.levels.WARN,
                { title = 'OpenChanges' }
            )
            revision = nil
        end

        RELOAD('utils.buffers').open_changes({ action = action, revision = revision, clear = true })
    end, {
        bang = true,
        nargs = '*',
        complete = completions.qf_file_options,
        desc = 'Open all modified files in the current git repository',
    })

    nvim.command.set('OpenConflicts', function(opts)
        RELOAD('utils.buffers').open_conflicts(opts)
    end, {
        nargs = '?',
        complete = completions.qf_file_options,
        desc = 'Open conflict files in the current git repository',
    })
end

-- NOTE: This could be smarter and list the hunks in the QF
nvim.command.set('ModifiedDump', function(_)
    RELOAD('utils.qf').dump_files(
        vim.tbl_filter(function(buf)
            return vim.bo[buf].modified
        end, vim.api.nvim_list_bufs()),
        { open = true }
    )
end, {
    desc = 'Dump all unsaved files into the QF',
})

nvim.command.set('ModifiedSave', function(_)
    local modified = vim.tbl_filter(function(buf)
        return vim.bo[buf].modified
    end, vim.api.nvim_list_bufs())
    for _, buf in ipairs(modified) do
        vim.api.nvim_buf_call(buf, function()
            vim.cmd.update()
        end)
    end
end, {
    desc = 'Save all modified buffers',
})

nvim.command.set('Qf2Loc', function(_)
    local qfutils = RELOAD 'utils.qf'
    qfutils.qf_loclist_switcher { loc = true }
end, { desc = "Move the current QF to the window's location list" })

nvim.command.set('Loc2Qf', function(_)
    local qfutils = RELOAD 'utils.qf'
    qfutils.qf_loclist_switcher()
end, { desc = "Move the current window's location list to the QF" })

nvim.command.set('TrimWhites', function(opts)
    RELOAD('utils.files').trimwhites(nvim.get_current_buf(), { opts.line1 - 1, opts.line2 })
end, { range = '%', desc = 'Alias to <,>s/\\s\\+$//g' })

nvim.command.set('ParseSSHConfig', function(_)
    local hosts = RELOAD('threads.parsers').sshconfig()
    for host, attrs in pairs(hosts) do
        STORAGE.hosts[host] = attrs
    end
end, { desc = 'Parse SSH config' })

nvim.command.set('VNC', function(opts)
    RELOAD('mappings').vnc(opts.args, { '-Quality=high' })
end, { complete = completions.ssh_hosts_completion, nargs = 1, desc = 'Open a VNC connection to the given host' })

if executable 'gh' then
    nvim.command.set('PRCreate', function(opts)
        if #opts.fargs > 0 then
            opts.fargs = vim.list_extend({ '--reviewer' }, { table.concat(opts.fargs, ',') })
        end
        if not opts.bang then
            table.insert(opts.fargs, '--draft')
        end
        opts.args = table.concat(opts.fargs, ' ')
        RELOAD('utils.gh').create_pr({ args = opts.fargs }, function(_)
            vim.notify('PR created! ', vim.log.levels.INFO, { title = 'GH' })
        end)
    end, {
        nargs = '*',
        complete = completions.reviewers,
        bang = true,
        desc = 'Open PR with the given reviewers defined in reviewers.json',
    })

    nvim.command.set('PrOpen', function(opts)
        local gh = RELOAD 'utils.gh'

        local pr
        if opts.args ~= '' then
            pr = tonumber(opts.args)
        elseif not opts.bang then
            gh.list_repo_pr({}, function(list_pr)
                local titles = vim.tbl_map(function(pull_request)
                    return pull_request.title
                end, vim.deepcopy(list_pr))
                vim.ui.select(
                    titles,
                    { prompt = 'Select PR: ' },
                    vim.schedule_wrap(function(choice)
                        if choice ~= '' then
                            local pr_id = vim.tbl_filter(function(pull_request)
                                return pull_request.title == choice
                            end, list_pr)[1].number
                            gh.open_pr(pr_id)
                        end
                    end)
                )
            end)
            return
        end

        gh.open_pr(pr)
    end, {
        nargs = 0,
        bang = true,
        desc = 'Open PR in the browser',
    })

    nvim.command.set('PrReady', function(opts)
        local is_ready = true
        if opts.args == 'draft' then
            is_ready = false
        end
        RELOAD('utils.gh').pr_ready(is_ready, function(_)
            local msg = ('PR move to %s'):format(opts.args == '' and 'ready' or opts.args)
            vim.notify(msg, vim.log.levels.INFO, { title = 'GH' })
        end)
    end, {
        nargs = '?',
        complete = completions.gh_pr_ready,
        desc = 'Set PR to ready or to draft',
    })

    nvim.command.set('EditReviewers', function(opts)
        local reviewers = { table.concat(opts.fargs, ',') }
        local action = opts.fargs[1]:gsub('^%-+', '')
        local command = action == 'add' and '--add-reviewer' or '--remove-reviewer'
        opts.fargs = vim.list_extend({ command }, reviewers)
        opts.args = table.concat(opts.fargs, ' ')
        RELOAD('utils.gh').edit_pr({ args = opts.fargs }, function(_)
            local msg = ('Reviewers %s were %s'):format(action .. 'ed', table.concat(reviewers, ''))
            vim.notify(msg, vim.log.levels.INFO, { title = 'GH' })
        end)
    end, {
        nargs = '+',
        complete = completions.gh_edit_reviewers,
        bang = true,
        desc = 'Add/Remove reviewers defined in reviewers.json',
    })
end

nvim.command.set('Argdo', function(opts)
    RELOAD('utils.arglist').exec(opts.args)
end, { nargs = '+', desc = 'argdo but without the final Press enter message', complete = 'command' })

nvim.command.set('Qf2Arglist', function()
    RELOAD('utils.qf').qf_to_arglist()
end, { desc = 'Dump qf files to the arglist' })

nvim.command.set('Loc2Arglist', function()
    RELOAD('utils.qf').qf_to_arglist { loc = true }
end, { desc = 'Dump loclist files to the arglist' })

nvim.command.set('Arglist2Qf', function()
    RELOAD('utils.qf').dump_files(vim.fn.argv())
end, { desc = 'Dump loclist files to the arglist' })

nvim.command.set('Arglist2Loc', function()
    RELOAD('utils.qf').dump_files(vim.fn.argv(), { win = 0 })
end, { desc = 'Dump loclist files to the arglist' })

nvim.command.set('ArgEdit', function(opts)
    RELOAD('utils.arglist').edit(opts.args)
end, { nargs = '?', complete = completions.arglist, desc = 'Edit a file in the arglist' })

nvim.command.set('ArgClear', function(opts)
    RELOAD('utils.arglist').clear(opts.bang)
end, { nargs = 0, bang = true, desc = 'Delete all or invalid arguments' })

nvim.command.set('ArgAddBuf', function(opts)
    local argadd = RELOAD('utils.arglist').add
    local cwd = vim.pesc(vim.loop.cwd() .. '/')
    local buffers = vim.tbl_map(function(buf)
        return (vim.api.nvim_buf_get_name(buf):gsub(cwd, ''))
    end, vim.api.nvim_list_bufs())
    local args = #opts.fargs > 0 and opts.fargs or { '%' }
    for _, arg in ipairs(args) do
        if arg:match '%*' then
            arg = (arg:gsub('%*', '.*'))
            local matches = {}
            for _, buf in ipairs(buffers) do
                if buf ~= '' and buf:match(arg) then
                    table.insert(matches, buf)
                end
            end
            argadd(matches)
        else
            argadd(arg)
        end
    end
end, { nargs = '*', complete = completions.buflist, desc = 'Add buffers to the arglist' })

nvim.command.set('ClearMarks', function()
    local deleted_marks = 0
    for idx = vim.fn.char2nr 'A', vim.fn.char2nr 'Z' do
        local letter = vim.fn.nr2char(idx)
        local mark = vim.api.nvim_get_mark(letter, {})
        local filename = mark[4]
        if filename ~= '' and not require('utils.files').is_file(filename) then
            deleted_marks = deleted_marks + 1
            vim.api.nvim_del_mark(letter)
        end
    end

    if deleted_marks > 0 then
        vim.notify('Deleted marks: ' .. deleted_marks, vim.log.levels.INFO, { title = 'ClearMarks' })
    end
end, { desc = 'Remove global marks of removed files' })

nvim.command.set('DumpMarks', function()
    local marks = {}
    for idx = vim.fn.char2nr 'A', vim.fn.char2nr 'Z' do
        local letter = vim.fn.nr2char(idx)
        local mark = vim.api.nvim_get_mark(letter, {})
        local filename = mark[4]
        if filename ~= '' and require('utils.files').is_file(filename) then
            marks[letter] = mark
        end
    end
    if next(marks) ~= nil then
        require('utils.files').dump_json('marks.json', marks)
        vim.notify('Marks dumped into marks.json', vim.log.levels.INFO, { title = 'DumpMarks' })
    end
end, { desc = 'Dump global marks in a local json file' })

nvim.command.set('RemoveForeignMarks', function()
    local utils = require 'utils.files'
    local deleted_marks = 0
    for idx = vim.fn.char2nr 'A', vim.fn.char2nr 'Z' do
        local letter = vim.fn.nr2char(idx)
        local mark = vim.api.nvim_get_mark(letter, {})
        if mark[4] ~= '' then
            local filename = mark[4]
            if utils.is_file(filename) then
                filename = utils.realpath(filename)
            end
            local cwd = vim.pesc(vim.loop.cwd())
            if not utils.is_file(filename) or not filename:match('^' .. cwd) then
                vim.api.nvim_del_mark(letter)
                deleted_marks = deleted_marks + 1
            end
        end
    end

    if deleted_marks > 0 then
        vim.notify('Deleted marks not in the CWD: ' .. deleted_marks, vim.log.levels.INFO, { title = 'RemoveMarks' })
    end
end, { desc = 'Remove all global marks that are outside of the CWD' })

nvim.command.set('Oldfiles', function()
    vim.ui.select(
        vim.v.oldfiles,
        { prompt = 'Select file: ' },
        vim.schedule_wrap(function(choice)
            if choice then
                vim.cmd.edit(choice)
            end
        end)
    )
end, { nargs = 0, desc = 'Edit a file from oldfiles' })

if not vim.g.lazy_setup and not vim.g.bare and not vim.g.minimal then
    nvim.command.set('SetupLazy', function()
        nvim.setup.lazy(true)
    end, { nargs = 0, desc = 'initial lazy setup' })
end

nvim.command.set('RemoteTermdebug', function(opts)
    RELOAD('utils.debug').remote_attach_debugger { hostname = opts.args }
end, {
    nargs = 1,
    desc = 'Start a Termdebug remote session using gdbserver',
    complete = completions.ssh_hosts_completion,
})

nvim.command.set('ClearBufNS', function(opts)
    local ns = vim.api.nvim_create_namespace(opts.args)
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end, {
    nargs = 1,
    desc = 'Clear buffer namespace',
    complete = completions.namespaces,
})

nvim.command.set('SetupMake', function()
    RELOAD('filetypes.make.utils').copy_template()
    RELOAD 'filetypes.make.mappings'
end, { nargs = 0, desc = 'Copy Makefile template into cwd' })

-- TODO: Support make and cmake
nvim.command.set('InitCppProject', function()
    local utils = require 'utils.files'

    for _, dir in ipairs { 'src', 'include' } do
        utils.mkdir(dir)
    end

    local config_path = vim.fn.stdpath('config'):gsub('\\', '/')
    local templates = {
        ['main.cpp'] = './src/main.cpp',
        ['compile_flags.txt'] = 'compile_flags.txt',
        ['clang-tidy'] = '.clang-tidy',
        ['clang-format'] = '.clang-format',
    }

    for src, dest in pairs(templates) do
        local template = string.format('%s/skeletons/%s', config_path, src)
        utils.copy(template, dest)
    end

    RELOAD 'filetypes.cpp.mappings'

    require('utils.git').exec.init()

    if executable 'make' then
        RELOAD('filetypes.make.utils').copy_template()
        RELOAD 'filetypes.make.mappings'
    end

    vim.cmd.edit 'src/main.cpp'
end, { force = true, desc = 'Initialize a C/C++ project' })
