return {
  {
    "neovim/nvim-lspconfig",
    ft = { "json", "jsonc" },
    opts = {
      servers = {
        jsonls = {
          settings = { --
            json = {
              schemas = {
                {
                  fileMatch = { "package.json" },
                  url = "https://json.schemastore.org/package.json",
                },
                {
                  fileMatch = { "tsconfig*.json" },
                  url = "https://json.schemastore.org/tsconfig.json",
                },
                {
                  fileMatch = { ".prettierrc", ".prettierrc.json", "prettier.config.json" },
                  url = "https://json.schemastore.org/prettierrc.json",
                },
                {
                  fileMatch = { ".eslintrc", ".eslintrc.json" },
                  url = "https://json.schemastore.org/eslintrc.json",
                },
                {
                  fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
                  url = "https://json.schemastore.org/babelrc.json",
                },
              },
            },
          },
        },
      },
    },
  },
}
