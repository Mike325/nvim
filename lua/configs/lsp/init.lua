vim.lsp.protocol.CompletionItemKind = {
    '', -- Text          = 1;
    '', -- Method        = 2;
    'ƒ', -- Function      = 3;
    '', -- Constructor   = 4;
    '識', -- Field         = 5;
    '', -- Variable      = 6;
    '', -- Class         = 7;
    'ﰮ', -- Interface     = 8;
    '', -- Module        = 9;
    '', -- Property      = 10;
    '', -- Unit          = 11;
    '', -- Value         = 12;
    '了', -- Enum          = 13;
    '', -- Keyword       = 14;
    '﬌', -- Snippet       = 15;
    '', -- Color         = 16;
    '', -- File          = 17;
    '渚', -- Reference     = 18;
    '', -- Folder        = 19;
    '', -- EnumMember    = 20;
    '', -- Constant      = 21;
    '', -- Struct        = 22;
    '鬒', -- Event         = 23;
    'Ψ', -- Operator      = 24;
    '', -- TypeParameter = 25;
}

local lsp = vim.F.npcall(require, 'lspconfig')

if not lsp then
    return false
end

local lsp_configs = require 'configs.lsp.servers'
local nvim = require 'nvim'
local executable = require('utils.files').executable

local preload = {
    clangd = {
        setup = function(init)
            local clangd = vim.F.npcall(require, 'clangd_extensions')
            if clangd then
                clangd.setup { server = init }
            else
                lsp.clangd.setup(init)
            end
        end,
    },
    ['rust-analyzer'] = {
        setup = function(init)
            local tools = vim.F.npcall(require, 'rust-tools')
            if tools then
                tools.setup { server = init }
            else
                lsp.rust_analyzer.setup(init)
            end
        end,
    },
}

local setup_func = {}
local function setup(ft)
    vim.validate { filetype = { ft, 'string' } }

    local function config_lsp(server)
        if
            ft == 'python'
            and (server.exec and server.exec ~= 'ruff' and executable 'ruff')
            and nvim.plugins.YouCompleteMe
        then
            return false
        end

        local config = server.config or server.exec
        if not setup_func[config] then
            setup_func[config] = function()
                local init = vim.deepcopy(server.options) or {}
                init.cmd = init.cmd or server.cmd
                local capabilities = vim.lsp.protocol.make_client_capabilities()
                if nvim.plugins['nvim-cmp'] then
                    local cmp_lsp = vim.F.npcall(require, 'cmp_nvim_lsp')
                    if cmp_lsp then
                        capabilities = vim.tbl_deep_extend('force', capabilities, cmp_lsp.default_capabilities())
                    end
                end
                init.capabilities = vim.tbl_deep_extend('keep', init.capabilities or {}, capabilities or {})
                if preload[config] then
                    preload[config].setup(init)
                else
                    lsp[config].setup(init)
                    return true
                end
            end
        end
        return false
    end

    local server_idx = RELOAD('configs.lsp.utils').check_language_server(ft)
    if server_idx then
        local server = RELOAD('configs.lsp.servers')[ft][server_idx]
        config_lsp(server)
        -- NOTE: Always setup ruff in lsp mode
        if ft == 'python' and (server.exec and server.exec ~= 'ruff' and executable 'ruff') then
            for _, serv in pairs(RELOAD('configs.lsp.servers')[ft]) do
                if serv.exec and serv.exec == 'ruff' then
                    config_lsp(serv)
                    break
                end
            end
        end
        return true
    end
    return false
end

local null_sources = {}
local null_ls = vim.F.npcall(require, 'null-ls')
local null_configs = require 'configs.lsp.null'

if null_ls and pcall(require, 'gitsigns') then
    table.insert(null_sources, null_ls.builtins.code_actions.gitsigns)
end

for filetype, _ in pairs(lsp_configs) do
    local has_server = setup(filetype)
    local null_config = null_configs[filetype]

    if not has_server and null_config then
        vim.list_extend(null_sources, null_config.servers)
    end
end

if executable 'jq' then
    local null_config = null_configs.json or {}
    vim.list_extend(null_sources, null_config.servers or {})
end

if null_ls and next(null_sources) ~= nil then
    null_ls.setup {
        sources = null_sources,
        debug = false,
    }
end

vim.api.nvim_create_autocmd('UIEnter', {
    desc = 'Delay LSP server setup until UI enters',
    group = vim.api.nvim_create_augroup('LspServerSetup', { clear = true }),
    once = true,
    pattern = '*',
    callback = function()
        for _, func in pairs(setup_func) do
            func()
        end
    end,
})

return {
    setup = setup,
}
