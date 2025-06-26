return {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        columns = {
            'icon',
            'permissions',
            'size',
            'mtime',
        },
        keymaps = {
            ['<C-v>'] = 'actions.select_vsplit',
            ['<C-x>'] = 'actions.select_split',
            ['<C-t>'] = 'actions.select_tab',
            ['<C-p>'] = 'actions.preview',
            ['<C-c>'] = 'actions.close',
            ['<C-r>'] = 'actions.refresh',
        },
        view_options = {
            show_hidden = true,
        },
    },
}

-- vim: ts=2 sts=2 sw=2 et
