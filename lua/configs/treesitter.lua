local nvim = require 'nvim'
local treesitter = vim.F.npcall(require, 'nvim-treesitter.configs')

if not treesitter then
    return false
end

local languages = {
    'bash',
    'bibtex',
    'c',
    'cmake',
    'comment',
    'cpp',
    'dockerfile',
    'go',
    'ini',
    'java',
    'json',
    'jsonc',
    'latex',
    'lua',
    'make',
    'markdown',
    'perl',
    'python',
    'query',
    'rst',
    'rust',
    'todotxt',
    'toml',
    'vim',
    'vimdoc',
    'yaml',
}

local parsers = require 'nvim-treesitter.parsers'

local cpp_tools = vim.F.npcall(require, 'nt-cpp-tools')
if cpp_tools then
    cpp_tools.setup {
        preview = {
            quit = '<ESC>',
            accept = '<CR>',
        },
        header_extension = 'hpp',
        source_extension = 'cpp',
    }
end

treesitter.setup {
    ensure_installed = languages,
    indent = {
        enable = true,
    },
    incremental_selection = {
        enable = false,
        -- keymaps = {
        --     init_selection = '<A-i>',
        --     scope_incremental = '<A-c>',
        --     node_incremental = '<A-I>',
        --     node_decremental = '<A-D>',
        -- },
    },
    highlight = {
        enable = true,
        disable = {
            'org',
            'make',
            nvim.plugins['todo-comments.nvim'] and 'comment' or nil,
        },
        additional_vim_regex_highlighting = { 'org' },
    },
    textobjects = {
        lsp_interop = {
            enable = true,
            -- border = 'none',
            peek_definition_code = {
                ['<A-f>'] = '@function.outer',
                ['<A-k>'] = '@class.outer',
            },
        },
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ['af'] = '@conditional.outer',
                ['if'] = '@conditional.inner',
                ['am'] = '@function.outer', -- Same as [m, ]m "method"
                ['im'] = '@function.inner',
                ['ak'] = '@class.outer',
                ['ik'] = '@class.inner',
                ['ia'] = '@parameter.inner',
                ['aa'] = '@parameter.inner',
                ['ir'] = '@loop.inner', -- "repeat" mnemonic
                ['ar'] = '@loop.outer',
                ['ac'] = '@comment.outer',
                ['ic'] = '@comment.outer',
            },
        },
        swap = {
            enable = true,
            swap_next = {
                -- ["<leader>k"] = "@class.outer",
                -- ["<leader>f"] = "@loop.outer",
                -- ["<leader>c"] = "@comment.outer",
                ['<leader>f'] = '@conditional.outer',
                ['<leader>a'] = '@parameter.inner',
                ['<leader>m'] = '@function.outer',
            },
            swap_previous = {
                -- ["<leader><leader>k"] = "@class.outer",
                -- ["<leader><leader>f"] = "@loop.outer",
                -- ["<leader><leader>c"] = "@comment.outer",
                ['<leader><leader>f'] = '@conditional.outer',
                ['<leader><leader>a'] = '@parameter.inner',
                ['<leader><leader>m'] = '@function.outer',
            },
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_previous_start = {
                ['[f'] = '@conditional.outer',
                ['[m'] = '@function.outer',
                ['[k'] = '@class.outer',
                ['[r'] = '@loop.outer',
                ['[C'] = '@comment.outer',
                -- ['[a'] = '@parameter.inner',
            },
            goto_next_start = {
                [']f'] = '@conditional.outer',
                [']m'] = '@function.outer',
                [']k'] = '@class.outer',
                [']r'] = '@loop.outer',
                [']C'] = '@comment.outer',
                -- [']a'] = '@parameter.inner',
            },
            goto_previous_end = {
                ['[F'] = '@conditional.outer',
                ['[M'] = '@function.outer',
                [']K'] = '@class.outer',
                ['[R'] = '@loop.outer',
                -- ["[C"] = '@comment.outer',
                -- ['[A'] = '@parameter.inner',
            },
            goto_next_end = {
                [']F'] = '@conditional.outer',
                [']M'] = '@function.outer',
                ['[K'] = '@class.outer',
                [']R'] = '@loop.outer',
                -- ["]C"] =  '@comment.outer',
                -- [']A'] = '@parameter.inner',
            },
        },
    },
    playground = {
        enable = true,
        disable = {},
        updatetime = 25,
        persist_queries = false,
        keybindings = {
            toggle_query_editor = 'o',
            toggle_hl_groups = 'i',
            toggle_injected_languages = 't',
            toggle_anonymous_nodes = 'a',
            toggle_language_display = 'I',
            focus_language = 'f',
            unfocus_language = 'F',
            update = 'R',
            goto_node = '<cr>',
            show_help = '?',
        },
    },
    refactor = {
        -- highlight_current_scope = { enable = true },
        smart_rename = {
            enable = true,
            keymaps = {
                smart_rename = '<A-r>',
            },
        },
        highlight_definitions = {
            enable = true,
            -- disable = disable,
        },
        navigation = {
            enable = true,
            keymaps = {
                goto_definition = '<leader><C-]>',
                list_definitions = '<A-l>',
                goto_next_usage = '<A-n>',
                goto_previous_usage = '<A-N>',
                -- list_definitions_toc = "<A-t>",
            },
        },
    },
    markid = { enable = false },
    tree_docs = {
        enable = false,
        keymaps = {
            doc_node_at_cursor = '<A-d>',
            doc_all_in_range = '<A-d>',
        },
        -- spec_config = {
        --     jsdoc = {
        --         slots = {
        --             class = { author = true },
        --         },
        --         processors = {
        --             author = function()
        --                 return ' * @author ' .. require('sys').username
        --             end,
        --         },
        --     },
        -- },
    },
}

local context = vim.F.npcall(require, 'treesitter-context')
if context then
    context.setup {}
end

local fts = {}
for lang, opts in pairs(parsers.list) do
    if parsers.has_parser(lang) then
        if opts.filetype ~= nil then
            lang = opts.filetype
        end
        fts[#fts + 1] = lang
        if opts.used_by ~= nil then
            vim.list_extend(fts, opts.used_by)
        end
    end
end

if #fts > 0 then
    -- TODO: Check module availability for each language
    nvim.autocmd.TreesitterAutocmds = {
        event = 'FileType',
        pattern = fts,
        command = 'setlocal foldenable foldmethod=expr foldexpr=nvim_treesitter#foldexpr()',
    }
end

-- Expose languages to VimL
nvim.g.ts_languages = fts

return fts
