return {
    {
        "neovim/nvim-lspconfig",
        ft = { "sh" }, -- Triggers on shell script files
        opts = {
            servers = {
                -- bashls doesn't require any special setup
                bashls = {},
            },
        },
    },
}
