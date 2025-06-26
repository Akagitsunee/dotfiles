return {
  {
    "neovim/nvim-lspconfig",
    -- The filetypes are moved to the top-level ft key for lazy-loading
    ft = { "html", "mdx", "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" }, --
    opts = {
      servers = {
        tailwindcss = {
          -- All the original keys are now nested inside the server config
          capabilities = (function() --
            local capabilities = require("blink.cmp").get_lsp_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            capabilities.textDocument.colorProvider = { dynamicRegistration = false }
            capabilities.textDocument.foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            }
            return capabilities
          end)(),
          init_options = { --
            userLanguages = {
              eelixir = "html-eex",
              eruby = "erb",
            },
          },
          settings = { --
            tailwindCSS = {
              validate = true,
              lint = {
                cssConflict = "warning",
                invalidApply = "error",
                invalidConfigPath = "error",
                invalidScreen = "error",
                invalidTailwindDirective = "error",
                invalidVariant = "error",
                recommendedVariantOrder = "warning",
              },
              experimental = {
                classRegex = {
                  "tw`([^`]*)",
                  'tw="([^"]*)',
                  'tw={"([^"}]*)',
                  "tw\\.\\w+`([^`]*)",
                  "tw\\(.*?\\)`([^`]*)",
                  { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                  { "cn\\(([^)]*)\\)",   "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                },
              },
            },
          },
        },
      },
    },
  },
}
