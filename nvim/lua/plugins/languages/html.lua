return {
    {
        "neovim/nvim-lspconfig",
        ft = { "html" },
        opts = {
            servers = {
                -- html doesn't require any special setup
                html = {},
            },
        },
    },
}
