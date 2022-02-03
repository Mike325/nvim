local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

if not ls.snippets.sh then
    require 'plugins.snippets.sh'
end

ls.filetype_extend('bash', { 'sh' })