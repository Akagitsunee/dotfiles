return {
  {
    "neovim/nvim-lspconfig",
    ft = { "lua" },
    opts = {
      servers = {
        lua_ls = {
          settings = { --
            Lua = {
              diagnostics = {
                globals = { "vim", "bit", "packer_plugins" },
              },
              hint = { enable = true },
            },
          },
        },
      },
    },
  },
}
