local nvim = require('mikecommon/nvim')

local function convert2settings(name)
    if name:find('-', 1, true) or name:find('.', 1, true) then
        name = name:gsub('-', '_')
        name = name:gsub('%.', '_')
    end
    return name:lower()
end

local function plugins_settings()
    -- TODO: Add glob function to call just the available configs
    for plugin, data in pairs(nvim.plugs) do
        local name = plugin
        local func_name = convert2settings(name)
        local ok, error_code = pcall(vim.api.nvim_call_function, 'plugins#'..func_name..'#init', {data})
        -- if not ok then
        --     -- print('Something failed "'..error_code..'" Happened trying to call '..'plugins#'..func_name..'#init')
        -- else
        --     -- print('Success calling plugins#'..func_name..'#init')
        -- end
    end
end

plugins_settings()
