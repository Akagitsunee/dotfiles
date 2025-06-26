return {
  {
    "neovim/nvim-lspconfig",
    ft = { "vue" }, --
    opts = {
      servers = {
        vuels = {
          init_options = { --
            config = {
              vetur = {
                completion = {
                  autoImport = true,
                  tagCasing = "kebab",
                },
              },
            },
          },
          on_attach = function(client, bufnr) --
            client.resolved_capabilities.document_formatting = false
          end,
        },
      },
    },
  },
}
