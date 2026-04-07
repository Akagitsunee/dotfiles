return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        svelte = {
          on_attach = function(client, bufnr)
            -- Disable the built-in LSP formatter so Prettierd takes full control
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
      },
    },
  },
}