return {
  {
    "neovim/nvim-lspconfig",
    ft = { "css", "scss", "less" }, -- Triggers on CSS and pre-processor files
    opts = {
      servers = {
        cssls = {
          -- Settings and on_attach are placed inside the server's config table
          settings = { --
            css = {
              lint = {
                unknownAtRules = "ignore",
              },
            },
            scss = {
              lint = {
                unknownAtRules = "ignore",
              },
            },
          },
          on_attach = function(client, bufnr) --
            client.server_capabilities.documentFormattingProvider = true
            client.server_capabilities.documentRangeFormattingProvider = true
          end,
        },
      },
    },
  },
}
