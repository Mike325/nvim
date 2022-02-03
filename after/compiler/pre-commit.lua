local nvim = require 'neovim'

local cmd = {
    'pre-commit',
}
nvim.ex.CompilerSet('makeprg=' .. table.concat(cmd, '\\ '))

-- local formats = vim.opt_global.errorformat:get()
local formats = {
    '%f:%l:%c: %t%n %m',
    '%f:%l:%c:%t: %m',
    '%f:%l:%c: %m',
    '%f:%l: %trror: %m',
    '%f:%l: %tarning: %m',
    '%f:%l: %tote: %m',
    '%f:%l:%m',
    '%f: %trror: %m',
    '%f: %tarning: %m',
    '%f: %tote: %m',
    '%f: Failed to json decode (%m: line %l column %c (char %*\\\\d))',
    '%f: Failed to json decode (%m)',
    '%E%f:%l:%c: fatal error: %m',
    '%E%f:%l:%c: error: %m',
    '%W%f:%l:%c: warning: %m',
    'Diff in %f:',
    '+++ %f',
    'reformatted %f',
}

nvim.ex.CompilerSet('errorformat=' .. table.concat(formats, ','):gsub(' ', '\\ '))

vim.b.current_compiler = 'pre-commit'