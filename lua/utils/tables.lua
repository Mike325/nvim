local M = {}

function M.has_attrs(tbl, attrs)
    assert(type(tbl) == type({}), debug.traceback('TBL must be a table'))

    if type(attrs) ~= type(tbl) then
        if tbl[attrs] ~= nil then
            return true
        end
        for _,val in pairs(tbl) do
            if val == attrs then
                return true
            end
        end
    else
        local has_attrs = true
        for _,attr in pairs(attrs) do
            has_attrs = M.has_attrs(tbl, attr)
            if not has_attrs then
                break
            end
        end
        if has_attrs then
            return true
        end
    end
    return false
end

function M.merge_uniq_list(dest, src)
    assert(vim.tbl_islist(dest), debug.traceback("Dest must be an array"))
    assert(vim.tbl_islist(src), debug.traceback("Src must be an array"))

    local tmp = vim.deepcopy(dest)
    for _, node in pairs(src) do
        if not M.has_attrs(tmp, node) then
            table.insert(tmp, node)
        end
    end
    return tmp
end

function M.clear_lst(lst)
    assert(vim.tbl_islist(lst), debug.traceback('clear_lst works only with array like tables'))
    local tmp = {}

    for _,val in pairs(lst) do
        val = val:gsub('%s+$', '')
        if not val:match('^%s*$') then
            tmp[#tmp + 1] = val
        end
    end

    return tmp
end

function M.str_to_clean_tbl(cmd_string)
    assert(type(cmd_string) == type(''), debug.traceback('cmd must be a string'))
    return M.clear_lst(vim.split(vim.trim(cmd_string), ' ', true))
end

-- NOTE: Took from http://lua-users.org/wiki/CopyTable
function M.shallowcopy(orig)
    assert(type(orig) == type({}), debug.traceback('shallowcopy receives a table'))
    local copy
    if type(orig) == type({}) then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function M.deepcopy(orig)
    assert(type(orig) == type({}), debug.traceback('deepcopy receives a table'))
    local copy
    if type(orig) == type({}) then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[M.deepcopy(orig_key)] = M.deepcopy(orig_value)
        end
        setmetatable(copy, M.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return M
