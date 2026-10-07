return {
  {
    'neovim/nvim-lspconfig',
    -- The filetypes are moved to the top-level ft key for lazy-loading
    ft = { 'html', 'mdx', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue', 'svelte' }, --
    opts = function(_, opts)
      local capabilities = require('utils.lsp').capabilities {
        textDocument = { colorProvider = { dynamicRegistration = false } },
      }

      opts.servers = vim.tbl_deep_extend('force', opts.servers or {}, {
        tailwindcss = {
          capabilities = capabilities,
          settings = {
            tailwindCSS = {
              -- `init_options.userLanguages` is deprecated upstream in favour of this.
              includeLanguages = {
                eelixir = 'html-eex',
                eruby = 'erb',
              },
              validate = true,
              lint = {
                cssConflict = 'warning',
                invalidApply = 'error',
                invalidConfigPath = 'error',
                invalidScreen = 'error',
                invalidTailwindDirective = 'error',
                invalidVariant = 'error',
                recommendedVariantOrder = 'warning',
              },
              experimental = {
                classRegex = {
                  'tw`([^`]*)',
                  'tw="([^"]*)',
                  'tw={"([^"}]*)',
                  'tw\\.\\w+`([^`]*)',
                  'tw\\(.*?\\)`([^`]*)',
                  { 'clsx\\(([^)]*)\\)', "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                  { 'cn\\(([^)]*)\\)', "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                },
              },
            },
          },
        },
      })
    end,
  },
}
