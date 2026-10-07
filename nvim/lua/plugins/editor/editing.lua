return {
  {
    'echasnovski/mini.surround',
    version = '*',
    event = 'VeryLazy',
    config = function()
      -- gs* instead of the default s*: a bare `s` is flash.nvim's jump key, and the
      -- shared prefix made it wait for 'timeoutlen' on every press. which-key already
      -- labels `gs` as "surround".
      require('mini.surround').setup {
        mappings = {
          add = 'gsa',
          delete = 'gsd',
          find = 'gsf',
          find_left = 'gsF',
          highlight = 'gsh',
          replace = 'gsr',
          update_n_lines = 'gsn',
        },
      }
    end,
  },
  { 'tpope/vim-sleuth', event = { 'BufReadPre', 'BufNewFile' } },
}

-- vim: ts=2 sts=2 sw=2 et
