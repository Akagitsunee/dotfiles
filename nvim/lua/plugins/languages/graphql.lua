return {
    {
        "neovim/nvim-lspconfig",
        ft = { "graphql" },
        opts = {
            servers = {
                -- graphql doesn't require any special setup
                graphql = {},
            },
        },
    },
}
