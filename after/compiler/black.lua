local set_compiler = RELOAD('utils.functions').set_compiler
set_compiler('black', {
    configs = {
        'pyproject.toml',
    },
})