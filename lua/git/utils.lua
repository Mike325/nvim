local executable = require('utils.files').executable

if not executable 'git' then
    return false
end

local M = {}

local function rm_colors(cmd)
    -- stylua: ignore
    return vim.list_extend(cmd or {}, {
        '-c', 'color.ui=off',
        '-c', 'color.branch=off',
        '-c', 'color.interactive=off',
        '-c', 'color.grep=off',
        '-c', 'color.log=off',
        '-c', 'color.diff=off',
        '-c', 'color.status=off',
    })
end

local function rm_pager(cmd)
    return vim.list_extend(cmd or {}, {
        '--no-pager',
    })
end

local function get_git_dir(cmd)
    if vim.b.project_root and vim.b.project_root.is_git then
        return vim.list_extend(cmd or {}, { '--git-dir', vim.b.project_root.git_dir })
    end
    return {}
end

local function exec_async_gitcmd(data)
    vim.validate { data = { data, 'table' } }

    local cmd = data.cmd
    vim.validate { cmd = { cmd, 'table' } }

    local callbacks = data.callbacks
    vim.validate {
        callbacks = {
            callbacks,
            function(c)
                return not c or vim.is_callable(c) or type(c) == type {}
            end,
            'valid callback or an array of callbacks',
        },
    }

    local silent = data.silent
    local gitcmd
    for i = 2, #cmd do
        if cmd[i]:sub(1, 1) ~= '-' then
            gitcmd = cmd[i]
            break
        end
    end

    local opts = data.opts or { pty = true }
    local progress = data.progress

    if require('sys').name == 'windows' then
        cmd = table.concat(cmd, ' ')
    end

    local async_git = RELOAD('jobs'):new {
        cmd = cmd,
        silent = silent,
        opts = opts,
        qf = {
            on_fail = {
                open = true,
                jump = false,
            },
            context = 'Git' .. (gitcmd or ''),
            title = 'Git ' .. (gitcmd or ''),
        },
    }
    if callbacks then
        callbacks = type(callbacks) ~= type {} and { callbacks } or callbacks
        for _, cb in pairs(callbacks) do
            async_git:add_callbacks(cb)
        end
    end
    async_git:start()
    if progress then
        async_git:progress()
    end
end

local function exec_sync_gitcmd(cmd, gitcmd)
    local ok, output = pcall(vim.fn.system, cmd)
    return ok and output or error(debug.traceback('Failed to execute: ' .. gitcmd .. ', ' .. output))
end

function M.get_git_cmd(gitcmd, args)
    local cmd = { 'git' }
    rm_colors(cmd)
    get_git_dir(cmd)
    rm_pager(cmd)
    table.insert(cmd, gitcmd)
    if type(args) == type {} and vim.tbl_islist(args) then
        vim.list_extend(cmd, args)
    end
    return cmd
end

function M.launch_gitcmd_job(opts)
    vim.validate { opts = { opts, 'table' } }
    vim.validate {
        gitcmd = {
            opts.gitcmd,
            function(g)
                return type(g) == type '' and g ~= ''
            end,
            'git cmd',
        },
        args = {
            opts.args,
            function(a)
                return not a or vim.tbl_islist(a)
            end,
            'git arguments',
        },
        jobopts = {
            opts.jobopts,
            function(j)
                return not j or type(j) == type {}
            end,
            'job opts',
        },
    }

    local gitcmd = opts.gitcmd
    local args = opts.args

    local cmd = M.get_git_cmd(gitcmd, args)
    exec_async_gitcmd {
        cmd = cmd,
        opts = opts.jobopts,
        silent = opts.silent,
        progress = opts.progress,
        callbacks = opts.callbacks,
    }
end

local function parse_status(status)
    vim.validate {
        status = {
            status,
            function(s)
                return type(s) == type '' or vim.tbl_islist(s)
            end,
            'valid git status format',
        },
    }

    if type(status) == 'string' then
        status = vim.split(status, '\n+')
    end

    local parsed = {}

    for _, gitfile in pairs(status) do
        if not parsed.branch and gitfile:match '^#%s+branch%.head' then
            parsed.branch = vim.split(gitfile, '%s+')[3]
        elseif not parsed.upstream and gitfile:match '^#%s+branch%.upstream' then
            parsed.upstream = vim.split(gitfile, '%s+')[3]
        elseif gitfile:sub(1, 1) ~= '#' then
            -- parsed.files = parsed.files or {}
            -- local line = vim.split(gitfile, '%s+')
            if gitfile:sub(1, 1) == '1' or gitfile:sub(1, 1) == '2' then
                local stage_status = gitfile:sub(3, 3)
                local wt_status = gitfile:sub(4, 4)
                if stage_status == 'A' or stage_status == 'M' or stage_status == 'D' then
                    parsed.stage = parsed.stage or {}
                    local filename = gitfile:sub(114, #gitfile)
                    if stage_status == 'M' then
                        stage_status = 'modified'
                    else
                        stage_status = stage_status == 'A' and 'added' or 'deleted'
                    end
                    parsed.stage[filename] = { status = stage_status }
                    -- parsed.files[filename] = 'staged'
                elseif stage_status == 'R' then
                    parsed.stage = parsed.stage or {}
                    local files = vim.split(gitfile:sub(119, #gitfile), '\t+') -- replace with %s+ ??
                    local filename = files[1]
                    parsed.stage[filename] = {
                        status = 'moved',
                        original = files[2],
                    }
                    -- parsed.files[filename] = 'staged'
                end
                if wt_status == 'M' then
                    parsed.workspace = parsed.workspace or {}
                    local filename = gitfile:sub(114, #gitfile)
                    parsed.workspace[filename] = {
                        status = 'modified',
                    }
                    -- parsed.files[filename] = 'workspace'
                end
            elseif gitfile:sub(1, 1) == '?' then
                parsed.untracked = parsed.untracked or {}
                local filename = gitfile:sub(3, #gitfile)
                parsed.untracked[#parsed.untracked + 1] = filename
                -- parsed.files[filename] = 'untracked'
                -- elseif gitfile:sub(1, 1) == 'u' then  -- TODO
                --     parsed.unmerge = parsed.unmerge or {}
            end
        end
    end
    return parsed
end

function M.status(callback)
    vim.validate {
        callback = {
            callback,
            function(c)
                return not callback or vim.is_callable(callback)
            end,
            'a callback function or nil',
        },
    }

    local gitcmd = 'status'
    local cmd = M.get_git_cmd(gitcmd, {
        '--branch',
        '--porcelain=2',
    })
    if not callback then
        return parse_status(exec_sync_gitcmd(cmd, gitcmd))
    end
    exec_async_gitcmd {
        cmd = cmd,
        silent = true,
        opts = {
            on_exit = function(job, rc)
                if rc ~= 0 then
                    error(debug.traceback 'Failed to get git status')
                end
                vim.defer_fn(function()
                    callback(parse_status(job:stdout()))
                end, 0)
            end,
        },
    }
end

return M
