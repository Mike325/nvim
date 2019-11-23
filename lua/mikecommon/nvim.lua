-- luacheck: globals unpack vim
local nvim = {}

nvim.plugs = nil
local ok, plugs = pcall(vim.api.nvim_get_var, 'plugs')

if ok then
    nvim.plugs = plugs
end


local function nvimFuncWrapper (name, ...)
    return vim.api.nvim_call_function(name, {...})
end

nvim.getcwd = function()
    return nvimFuncWrapper('getcwd')
end

nvim.has        = function(feature) return nvimFuncWrapper('has', feature) end
nvim.executable = function(program) return nvimFuncWrapper('executable', program) end
nvim.exepath    = function(program) return nvimFuncWrapper('exepath', program) end
nvim.system     = function(cmd) return nvimFuncWrapper('system', cmd) end
nvim.systemlist = function(cmd) return nvimFuncWrapper('systemlist', cmd) end
nvim.split      = function(str, pattern, keepempty) return nvimFuncWrapper('split', str, pattern, keepempty) end
nvim.join       = function(str, separator) return nvimFuncWrapper('join', str, separator) end

nvim.realpath = function(path)
    path = path == '.' and getcwd() or path
    return nvimFuncWrapper('fnamemodify', path, ':p')
end

nvim.globpath = function(path, expr)
    path = path == '.' and getcwd() or path
    local nosuf = false
    local list = true
    return nvimFuncWrapper('globpath', path, expr, nosuf, list)
end

nvim.finddir = function(name, path, count)
    path = path == '.' and getcwd() or path
    return nvimFuncWrapper('finddir', name, path, count)
end

nvim.findfile= function(name, path, count)
    path = path == '.' and getcwd() or path
    return nvimFuncWrapper('findfile', name, path, count)
end

nvim.json = {}

nvim.json.decode = function(json) return nvimFuncWrapper('json_decode', json) end
nvim.json.encode = function(json) return nvimFuncWrapper('json_encode', json) end
-- nvim.json.read   = function(json) return nvimFuncWrapper('json_encode', json) end
-- nvim.json.write  = function(json) return nvimFuncWrapper('json_encode', json) end

nvim.has_version = function(version)
    return vim.api.nvim_call_function('has', {'nvim-'..version})
end

return nvim
