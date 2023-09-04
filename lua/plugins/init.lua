local ok, packer = pcall(require, 'packer')

if not ok then
    return false
end

local has_compiler
local has_python = vim.fn.executable 'python3' == 1 or vim.fn.executable 'python' == 1
local is_win = vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1
if is_win then
    -- NOTE: windows' clang by default needs msbuild to compile treesitter parsers,
    has_compiler = vim.fn.executable 'gcc' == 1
else
    has_compiler = vim.fn.executable 'gcc' == 1 or vim.fn.executable 'clang' == 1
end

-- local has_make = vim.fn.executable('make') == 1

packer.init {
    -- log = {level = 'debug'},
    luarocks = { python_cmd = vim.fn.executable 'python3' == 1 and 'python3' or 'python' },
    profile = {
        enable = false,
        threshold = 1, -- the amount in ms that a plugins load time must be over for it to be included in the profile
    },
    display = {
        open_fn = require('packer.util').float,
    },
    git = {
        clone_timeout = 90, -- Timeout, in seconds, for git clones
    },
    -- max_jobs = is_win and 8 or nil,
    autoremove = true,
}

-- TODO: There are alot of conditions that should be check at "build" time and not at runtime
--       to speed up startup time
packer.startup(function()
    -- BUG: Seems like luarocks is not supported in windows
    if has_compiler and has_python then
        use_rocks { 'luacheck', 'jsregexp', 'lua-yaml' }
    end

    use 'wbthomason/packer.nvim'

    use { 'nanotee/luv-vimdocs', event = 'CmdlineEnter' }
    use { 'tweekmonster/startuptime.vim', cmd = { 'StartupTime' } }

    use {
        cond = function()
            return not vim.env.NO_COOL_FONTS
        end,
        'kyazdani42/nvim-web-devicons',
    }
    use { 'kevinhwang91/nvim-bqf' }

    use { 'nvim-lua/popup.nvim' }
    use { 'nvim-lua/plenary.nvim' }
    use { 'rcarriga/nvim-notify' }
    use { 'tpope/vim-abolish' }

    use {
        'chrisgrieser/nvim-various-textobjs',
        config = function()
            require('various-textobjs').setup {
                useDefaultKeymaps = false,
            }

            vim.keymap.set({ 'o', 'x' }, 'ie', function()
                require('various-textobjs').entireBuffer()
            end)

            -- NOTE: Add missing key text-obj?
            vim.keymap.set({ 'o', 'x' }, 'av', function()
                require('various-textobjs').value(true)
            end)
            vim.keymap.set({ 'o', 'x' }, 'iv', function()
                require('various-textobjs').value(true)
            end)

            vim.keymap.set({ 'o', 'x' }, 'ii', function()
                require('various-textobjs').indentation(true, true)
            end)
            vim.keymap.set({ 'o', 'x' }, 'ai', function()
                require('various-textobjs').indentation(false, false)
            end)
        end,
    }

    use {
        'catppuccin/nvim',
        as = 'catppuccin',
        config = function()
            -- vim.g.tokyonight_style = 'night'
            require('catppuccin').setup {
                flavour = 'mocha', -- latte, frappe, macchiato, mocha
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    nvimtree = false,
                    telescope = true,
                    notify = true,
                    mini = true,
                    hop = true,
                    dap = {
                        enabled = true,
                        enable_ui = true,
                    },
                    native_lsp = {
                        enabled = true,
                    },
                    treesitter = true,
                    treesitter_context = true,
                    -- lsp_trouble = true,
                    vimwiki = true,
                },
            }
            vim.cmd.colorscheme 'catppuccin'
        end,
    }

    use {
        'tami5/sqlite.lua',
        module = 'sqlite',
        cond = function()
            return require('sys').has_sqlite
        end,
    }

    use {
        'lervag/vimtex',
        cond = function()
            return vim.fn.executable 'latexmk' == 1 and not vim.env.VIM_MIN and not vim.g.minimal
        end,
        setup = function()
            require 'plugins.vimtex'
        end,
        ft = { 'bib', 'tex', 'latex', 'bibtex' },
    }

    use {
        'norcalli/nvim-colorizer.lua',
        config = function()
            vim.opt.termguicolors = true
            require('colorizer').setup()
        end,
        event = { 'CursorHold', 'CursorMoved', 'InsertEnter' },
    }

    use { 'tpope/vim-fugitive' }
    use { 'junegunn/gv.vim', cmd = 'GV', wants = 'vim-fugitive' }
    use { 'tpope/vim-repeat' }

    use {
        'tpope/vim-surround',
        event = 'VimEnter',
        setup = function()
            vim.g['surround_' .. vim.fn.char2nr '¿'] = '¿\r?'
            vim.g['surround_' .. vim.fn.char2nr '?'] = '¿\r?'
            vim.g['surround_' .. vim.fn.char2nr '¡'] = '¡\r!'
            vim.g['surround_' .. vim.fn.char2nr '!'] = '¡\r!'
            vim.g['surround_' .. vim.fn.char2nr ';'] = ':\r:'
            vim.g['surround_' .. vim.fn.char2nr ':'] = ':\r:'
            vim.g['surround_' .. vim.fn.char2nr 'q'] = [[``\r'']]
        end,
    }

    use {
        'ojroques/vim-oscyank',
        event = 'VimEnter',
        setup = function()
            vim.g.oscyank_silent = true
        end,
        config = function()
            require 'plugins.oscyank'
        end,
    }

    use {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = function()
            require 'plugins.pairs'
        end,
    }

    use {
        'Yggdroot/indentLine',
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        setup = function()
            vim.g.indentLine_fileTypeExclude = {
                'Telescope',
                'TelescopePrompt',
                'TelescopeResults',
                'log',
                'help',
                'packer',
            }

            vim.g.indentLine_bufTypeExclude = {
                'terminal',
                'man',
                'nofile',
            }

            vim.g.indentLine_bufNameExclude = {
                'term://.*',
                'man://.*',
            }
        end,
    }

    use {
        'sindrets/diffview.nvim',
        -- event = 'CmdlineEnter',
        -- cmd = { 'DiffviewToggle', 'DiffviewFileHistory' },
        cond = function()
            local is_min = vim.env.VIM_MIN or vim.g.minimal
            return not is_min and require('storage').has_version('git', { '2', '31', '0' })
        end,
        config = function()
            require 'plugins.diffview'
            vim.keymap.set(
                'n',
                '<leader>D',
                '<cmd>DiffviewOpen<CR>',
                { noremap = true, silent = true, desc = 'Open DiffView' }
            )
        end,
        cmd = { 'DiffviewOpen', 'DiffviewFileHistory', 'DiffviewLog' },
        requires = 'nvim-lua/plenary.nvim',
    }

    use {
        'lewis6991/gitsigns.nvim',
        event = { 'CursorHold', 'CursorHoldI' },
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        requires = 'nvim-lua/plenary.nvim',
        config = function()
            require('gitsigns').setup {
                -- word_diff = true,
                -- current_line_blame = true,
                -- current_line_blame_opts = {
                --     virt_text = true,
                --     virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
                --     delay = 1000,
                --     ignore_whitespace = false,
                -- },
                -- current_line_blame_formatter_opts = {
                --     relative_time = false,
                -- },
                on_attach = function(bufnr)
                    local opts = {
                        -- noremap = true,
                        buffer = bufnr,
                    }
                    local keymaps = {
                        [']c'] = {
                            mode = 'n',
                            mapping = function()
                                if vim.opt_local.diff:get() then
                                    vim.cmd.normal { bang = true, args = { ']c' } }
                                else
                                    require('gitsigns.actions').next_hunk()
                                end
                            end,
                        },
                        ['[c'] = {
                            mode = 'n',
                            mapping = function()
                                if vim.opt_local.diff:get() then
                                    vim.cmd.normal { bang = true, args = { '[c' } }
                                else
                                    require('gitsigns.actions').prev_hunk()
                                end
                            end,
                        },
                        ['=s'] = { mode = { 'n', 'v' }, mapping = '<cmd>lua require"gitsigns".stage_hunk()<CR>' },
                        ['=S'] = { mode = 'n', mapping = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>' },
                        ['=u'] = { mode = { 'n', 'v' }, mapping = '<cmd>lua require"gitsigns".reset_hunk()<CR>' },
                        ['=U'] = { mode = 'n', mapping = '<cmd>lua require"gitsigns".reset_buffer()<CR>' },
                        ['=f'] = { mode = 'n', mapping = '<cmd>lua require"gitsigns".preview_hunk()<CR>' },
                        ['=M'] = {
                            mode = 'n',
                            mapping = '<cmd>lua require"gitsigns".blame_line{full=false, ignore_whitespace=true}<CR>',
                        },

                        -- Text objects
                        ['ih'] = {
                            mode = { 'o', 'x' },
                            mapping = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                        },
                        ['ah'] = {
                            mode = { 'o', 'x' },
                            mapping = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                        },
                    }

                    for lhs, rhs in pairs(keymaps) do
                        vim.keymap.set(rhs.mode, lhs, rhs.mapping, opts)
                    end
                end,
            }
        end,
    }

    use {
        'glacambre/firenvim',
        cond = function()
            local ssh = vim.env.SSH_CONNECTION or false
            local min = vim.env.VIM_MIN ~= nil or vim.g.minimal ~= nil
            local firenvim = vim.g.started_by_firenvim ~= nil
            return (not min and not ssh) or firenvim
        end,
        config = function()
            if vim.g.started_by_firenvim ~= nil then
                vim.api.nvim_set_keymap('n', '<C-z>', '<cmd>call firenvim#hide_frame()<CR>', { noremap = true })
            end
        end,
        run = function()
            vim.fn['firenvim#install'](0)
        end,
    }

    use {
        'phaazon/hop.nvim',
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        config = function()
            require 'plugins.hop'
        end,
    }

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require 'plugins.treesitter'
        end,
        cond = function()
            local compiler
            if vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1 then
                compiler = vim.fn.executable 'gcc' == 1
            else
                compiler = vim.fn.executable 'gcc' == 1 or vim.fn.executable 'clang' == 1
            end
            return compiler
        end,
        requires = {
            { 'nvim-treesitter/playground' },
            { 'nvim-treesitter/nvim-treesitter-refactor' },
            { 'nvim-treesitter/nvim-treesitter-textobjects' },
            { 'Badhi/nvim-treesitter-cpp-tools' },
            { 'nvim-treesitter/nvim-treesitter-context' },
            { 'ziontee113/query-secretary' },
            -- { 'David-Kunz/markid' },
            -- { 'nvim-treesitter/nvim-tree-docs' },
        },
    }

    use {
        'danymat/neogen',
        config = function()
            require 'plugins.neogen'
        end,
        cmd = { 'Neogen' },
        requires = 'nvim-treesitter/nvim-treesitter',
    }

    -- NOTE: Replace by treesitter_context
    -- use {
    --     'SmiteshP/nvim-gps',
    --     config = function()
    --         require('nvim-gps').setup()
    --     end,
    --     requires = 'nvim-treesitter/nvim-treesitter',
    --     after = 'nvim-treesitter',
    -- }

    use {
        'nvim-telescope/telescope.nvim',
        config = function()
            require 'plugins.telescope'
        end,
        requires = {
            { 'nvim-lua/plenary.nvim' },
            { 'nvim-lua/popup.nvim' },
        },
    }

    use {
        'nvim-telescope/telescope-fzf-native.nvim',
        module = { 'fzf_lib', 'telescope' },
        run = 'make',
        cond = function()
            local compiler
            if vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1 then
                compiler = vim.fn.executable 'gcc' == 1
            else
                compiler = vim.fn.executable 'gcc' == 1 or vim.fn.executable 'clang' == 1
            end
            return compiler
        end,
    }

    use {
        'neovim/nvim-lspconfig',
        config = function()
            require 'plugins.lsp'
        end,
        after = 'telescope.nvim',
        requires = {
            { 'weilbith/nvim-floating-tag-preview' },
        },
    }

    use {
        'L3MON4D3/LuaSnip',
        config = function()
            require 'plugins.luasnip'
        end,
    }

    use {
        'hrsh7th/nvim-cmp',
        requires = {
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-nvim-lua' },
            { 'hrsh7th/cmp-nvim-lsp-signature-help' },
            { 'onsails/lspkind-nvim' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'ray-x/cmp-treesitter' },
            { 'lukas-reineke/cmp-under-comparator' },
            { 'hrsh7th/cmp-cmdline' },
        },
        config = function()
            require 'plugins.cmp'
        end,
        -- after = 'nvim-lspconfig',
    }

    use {
        'AckslD/nvim-neoclip.lua',
        config = function()
            local db_path
            local has_sqlite = require('sys').has_sqlite
            if has_sqlite then
                db_path = require('sys').db_root .. '/neoclip.sqlite3'
            end
            require('neoclip').setup {
                enable_persistent_history = has_sqlite,
                db_path = db_path,
                default_register = '+',
                keys = {
                    telescope = {
                        i = {
                            select = '<CR>',
                            paste = '<A-p>',
                            paste_behind = '<A-P>',
                        },
                        n = {
                            select = '<CR>',
                            paste = 'p',
                            paste_behind = 'P',
                        },
                    },
                },
            }
            -- Since we need to load after telescope, it should be safe to call this here
            require('telescope').load_extension 'neoclip'
        end,
        cond = function()
            -- Windows throws an error complaining it has an invalid syntax, I look in to it later
            return vim.fn.has 'win32' == 0
        end,
        requires = {
            { 'nvim-telescope/telescope.nvim' },
            (require('sys').has_sqlite and { 'tami5/sqlite.lua' } or nil),
        },
    }

    use {
        'vimwiki/vimwiki',
        setup = function()
            vim.g.vimwiki_list = {
                { path = '~/notes/', syntax = 'markdown', ext = '.md' },
                { path = '~/work/', syntax = 'markdown', ext = '.md' },
            }
            vim.g.vimwiki_hl_headers = 1
            vim.g.vimwiki_hl_cb_checked = 2
            vim.g.vimwiki_listsyms = ' ○◐●✓'
            vim.g.vimwiki_listsym_rejected = '✗'
        end,
        -- config = function()
        --     require 'plugins.vimwiki'
        -- end,
    }

    -- TODO: Add neovim 0.5 compatibility layer/setup
    use {
        'jose-elias-alvarez/null-ls.nvim',
        lock = true,
        -- wants = { 'nvim-lspconfig', 'plenary.nvim' },
        requires = {
            { 'neovim/nvim-lspconfig' },
            { 'nvim-lua/plenary.nvim' },
        },
    }

    use {
        'echasnovski/mini.nvim',
        config = function()
            require 'plugins.mini'
        end,
    }

    use {
        'mfussenegger/nvim-dap',
        -- event = { 'CursorHold', 'CmdlineEnter' },
        -- cmd = { 'DapStart', 'DapContinue' },
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        config = function()
            require 'plugins.dap'
        end,
        requires = {
            {
                'rcarriga/nvim-dap-ui',
                cond = function()
                    return not vim.env.VIM_MIN and not vim.g.minimal
                end,
            },
        },
    }

    use {
        'nvim-lualine/lualine.nvim',
        config = function()
            require 'plugins.lualine'
        end,
        requires = {
            { 'arkav/lualine-lsp-progress' },
        },
    }

    use {
        'rhysd/git-messenger.vim',
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        setup = function()
            vim.g.git_messenger_no_default_mappings = 1
        end,
        config = function()
            vim.api.nvim_set_keymap('n', '=m', '<Plug>(git-messenger)', { silent = true, nowait = true })
        end,
    }

    use {
        'tommcdo/vim-lion',
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        config = function()
            vim.g.lion_squeeze_spaces = 1
        end,
    }

    use {
        'folke/todo-comments.nvim',
        cond = function()
            local no_min = vim.env.VIM_MIN == nil and vim.g.minimal == nil
            local has_rg = vim.fn.executable 'rg' == 1
            return no_min and has_rg
        end,
        config = function()
            require 'plugins.todos'
        end,
        requires = {
            {
                'folke/trouble.nvim',
                cond = function()
                    return not vim.env.VIM_MIN and not vim.g.minimal
                end,
                config = function()
                    require 'plugins.trouble'
                end,
            },
        },
    }
end)

if has_compiler then
    local rocks = require 'packer.luarocks'
    rocks.install_commands()
end
