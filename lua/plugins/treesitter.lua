local compiler
if vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1 then
    compiler = vim.fn.executable 'gcc' == 1
else
    compiler = vim.fn.executable 'gcc' == 1 or vim.fn.executable 'clang' == 1
end

return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require 'configs.treesitter'
        end,
        cond = compiler ~= nil,
        lazy = false,
        priority = 1,
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter-refactor' },
            { 'nvim-treesitter/nvim-treesitter-textobjects' },
        },
    },
    -- { 'David-Kunz/markid' },
    -- { 'nvim-treesitter/nvim-tree-docs' },
    {
        'nvim-treesitter/playground',
        cmd = 'TSPlaygroundToggle',
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter' },
        },
    },
    {
        'nvim-treesitter/nvim-treesitter-context',
        name = 'treesitter-context',
        event = { 'CursorHold', 'CursorHoldI' },
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter' },
        },
    },
    {
        'ziontee113/query-secretary',
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter' },
        },
    },
    {
        'Badhi/nvim-treesitter-cpp-tools',
        cmd = {
            'TSCppDefineClassFunc',
            'TSCppMakeConcreteClass',
            'TSCppRuleOf3extobjects',
            'TSCppRuleOf5',
        },
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter' },
        },
        name = 'nt-cpp-tools',
        opts = {
            {
                preview = {
                    quit = '<ESC>', -- optional keymapping for quit preview
                    accept = '<CR>', -- optional keymapping for accept preview
                },
                header_extension = 'hpp', -- optional
                source_extension = 'cpp', -- optional
            },
        },
    },
    {
        'danymat/neogen',
        config = function()
            require 'configs.neogen'
        end,
        cmd = { 'Neogen' },
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter' },
        },
    },
}
