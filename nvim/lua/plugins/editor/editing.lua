return {
    {
        'echasnovski/mini.surround',
        version = '*',
        config = function()
            require('mini.surround').setup()
        end,
    },
    { 'tpope/vim-sleuth', lazy = false },
}


-- vim: ts=2 sts=2 sw=2 et
