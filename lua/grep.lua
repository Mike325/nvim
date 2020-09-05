local nvim = require'nvim'

if not nvim.has('nvim-0.5') then
    return nil
end

_G.Grep = {}

local grepjobs = {}

local function on_data(id, data, event)
    if data ~= nil and #data > 0 then
        vim.list_extend(grepjobs[id].data, data)
    end
end

local function on_exit(id, exit_code, event)
    if exit_code == 0 then
        local lines = {}

        for index, line in pairs(grepjobs[id].data) do
            line = vim.trim(line)
            if vim.fn.empty(line) == 0 and line ~= '\n' then
                lines[#lines + 1] = grepjobs[id].data[index]
            end
        end

        vim.fn.setqflist(
            {},
            'r',
            {
                contex = 'AsyncGrep',
                efm = grepjobs[id].format,
                lines = lines,
                title = 'Grep '..grepjobs[id].search,
            }
        )

        if vim.fn.getcwd() == grepjobs[id].cwd then
            local orientation = vim.o.splitbelow and 'botright' or 'topleft'
            nvim.command(orientation .. ' copen')
        else
            print('Grep '..grepjobs[id].search .. ' finished')
        end

    elseif exit_code == 1 then
        vim.fn.setqflist(
            {},
            'r',
            {
                contex = 'AsyncGrep',
                title = 'No results for '..grepjobs[id].search,
            }
        )
        nvim.echoerr('No results for '..grepjobs[id].search)
    else
        vim.fn.setqflist(
            {},
            'r',
            {
                contex = 'AsyncGrep',
                efm = grepjobs[id].format,
                lines = grepjobs[id].data,
                title = 'Error, Grep '..grepjobs[id].search..' exited with '..exit_code,
            }
        )
        nvim.echoerr('Grep exited with '..exit_code)
    end
    grepjobs[id] = nil
end

function _G.Grep.QueueJob(...)

    local cmd = vim.bo.grepprg or vim.o.grepprg

    local cwd = vim.fn.getcwd()
    local format = vim.o.grepformat

    for id, job in pairs(grepjobs) do
        if job['cwd'] == cwd then
            vim.fn.jobstop(id)
        end
    end

    local args = {...}

    local flags = {}
    local search = {}
    for _, arg in pairs(args) do
        if arg:sub(1, 1) == '-' then
            flags[#flags + 1] = arg
        else
            search[#search + 1] = arg
        end
    end

    cmd = vim.split(cmd, ' ')
    local prg = cmd[1]

    table.remove(cmd, 1)

    flags = string.format('%s %s', vim.fn.join(cmd, ' '), vim.fn.join(flags, ' '))
    search = vim.fn.join(search, ' ')

    local job = string.format('%s %s %s', prg, flags, nvim.fn.shellescape(search))

    local id = vim.fn.jobstart(
        job,
        {
            cwd = cwd,
            on_stdout = on_data,
            on_stderr = on_data,
            on_exit   = on_exit,
        }
    )

    grepjobs[id] = {
        id = id,
        cmd = prg,
        flags = flags,
        search = search,
        format = format,
        data = {},
        cwd = cwd,
    }

end

nvim.nvim_set_command(
    'Grep',
    'call v:lua.Grep.QueueJob(<f-args>)',
    {nargs = '+', force = true}
)

return grepjobs
