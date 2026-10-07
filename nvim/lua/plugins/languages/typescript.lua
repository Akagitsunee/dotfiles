return {
  {
    'neovim/nvim-lspconfig',
    ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    opts = function(_, opts)
      local utils = require 'utils.filter'

      -- Filter out .d.ts results when jumping to definitions with more
      -- than one candidate (e.g. React component + its type declaration)
      local handlers = {
        ['textDocument/definition'] = function(err, result, method, ...)
          if vim.islist(result) and #result > 1 then
            local filtered_result = utils.filter(result, utils.filterReactDTS)
            return vim.lsp.handlers['textDocument/definition'](err, filtered_result, method, ...)
          end
          vim.lsp.handlers['textDocument/definition'](err, result, method, ...)
        end,
      }

      opts.servers = vim.tbl_deep_extend('force', opts.servers or {}, {
        vtsls = {
          handlers = handlers,
          on_attach = function(client)
            -- Prettier owns formatting, not vtsls
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
          settings = {
            typescript = {
              inlayHints = {
                parameterNames = { enabled = 'literals', suppressWhenArgumentMatchesName = false },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = false },
                propertyDeclarationTypes = { enabled = false },
                functionLikeReturnTypes = { enabled = false },
                enumMemberValues = { enabled = true },
              },
              preferences = {
                quotePreference = 'auto',
                importModuleSpecifierEnding = 'auto',
              },
            },
            javascript = {
              inlayHints = {
                parameterNames = { enabled = 'literals', suppressWhenArgumentMatchesName = false },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = false },
                propertyDeclarationTypes = { enabled = false },
                functionLikeReturnTypes = { enabled = false },
                enumMemberValues = { enabled = true },
              },
            },
          },
        },
      })
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
