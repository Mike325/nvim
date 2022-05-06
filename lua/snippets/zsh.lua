local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

if #ls.get_snippets 'sh' == 0 then
    ls.add_snippets('sh', require 'snippets.sh')
end

ls.filetype_extend('zsh', { 'sh' })
return