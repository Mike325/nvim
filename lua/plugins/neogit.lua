local load_module = require('utils.functions').load_module

local neogit = load_module 'neogit'

if neogit == nil then
    return false
end

local nvim = require 'neovim'
local has_diffview = load_module 'diffview'

neogit.setup {
    -- disable_signs = true,
    signs = {
        --        {CLOSED, OPENED}
        section = { '❯', 'v' },
        item = { '❯', 'v' },
        -- hunk = { "", "" },
    },
    disable_commit_confirmation = true,
    integrations = {
        diffview = has_diffview ~= nil,
    },
    mappings = {
        status = {
            ['='] = 'Toggle',
        },
    },
}

if not nvim.plugins['vim-fugitive'] then
    nvim.command.set('G', function()
        require('neogit').open { kind = 'vsplit' }
    end)
end

vim.keymap.set('n', '=n', '<cmd>lua require"neogit".open({ kind = "vsplit" })<cr>', { silent = true, noremap = true })

return true
