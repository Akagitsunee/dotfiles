return {
  {
    "neovim/nvim-lspconfig",
    ft = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "html" },
    opts = {
      servers = {
        eslint = {
          settings = { --
            codeAction = {
              disableRuleComment = {
                enable = true,
                location = "separateLine",
              },
              showDocumentation = {
                enable = true,
              },
            },
            codeActionOnSave = {
              enable = false,
              mode = "all",
            },
            format = true,
            nodePath = "",
            onIgnoredFiles = "off",
            packageManager = "npm",
            quiet = false,
            rulesCustomizations = {},
            run = "onType",
            useESLintClass = false,
            validate = "on",
            workingDirectory = {
              mode = "location",
            },
          },
          on_attach = function(client, bufnr) --
            client.server_capabilities.documentFormattingProvider = true
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
          end,
        },
      },
    },
  },
}
