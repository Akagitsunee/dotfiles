return {
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function(_, opts)
      require('which-key').setup(opts)
    end,
    opts = {
      preset = 'helix',
      win = {
        border = _G.config.ui.border,
        wo = { winblend = _G.config.ui.winblend },
      },
      sort = { 'manual', 'local', 'order', 'group', 'alphanum', 'mod' },
      spec = {
        {
          mode = { 'n', 'v' },
          { '<leader>c', group = 'Code / LSP', icon = _G.config.icons.groups.code },
          { '<leader>d', group = 'Debug', icon = _G.config.icons.groups.debug },
          { '<leader>e', group = 'Explorer', icon = _G.config.icons.groups_simple.explorer },
          { '<leader>f', group = 'Find', icon = _G.config.icons.groups.find },
          { '<leader>g', group = 'Git', icon = _G.config.icons.groups.git },
          { '<leader>l', group = 'Lazy', icon = _G.config.icons.groups.lazy },
          { '<leader>q', group = 'Quit', icon = _G.config.icons.groups.quit },
          { '<leader>s', group = 'Search', icon = _G.config.icons.groups.search },
          { '<leader>t', group = 'Text', icon = _G.config.icons.groups.text },
          { '<leader>u', group = 'UI', icon = _G.config.icons.groups.ui },
          { '<leader>v', group = 'Utilities', icon = _G.config.icons.ui.vim },
          { '<leader>x', group = 'Lists / Trouble', icon = _G.config.icons.groups.trouble },

          { '[', group = 'prev', icon = { icon = _G.config.icons.groups.prev, color = 'blue' } },
          { ']', group = 'next', icon = { icon = _G.config.icons.groups.next, color = 'blue' } },
          { 'g', group = 'goto', icon = { icon = _G.config.icons.groups.go_to, color = 'cyan' } },
          { 'gs', group = 'surround', icon = { icon = _G.config.icons.groups.surround, color = 'yellow' } },
          { 'z', group = 'fold', icon = { icon = _G.config.icons.groups.fold, color = 'purple' } },
          { 'gx', desc = 'Open with system app' },
        },
      },
    },
    -- Your custom key triggers
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show { global = false }
        end,
        desc = 'Buffer Keymaps (which-key)',
      },
      {
        '<c-w><space>',
        function()
          require('which-key').show { keys = '<c-w>', loop = true }
        end,
        desc = 'Window Hydra Mode (which-key)',
      },
    },
  },
  -- Snacks for managing UI state
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = false },
      dashboard = {
        preset = {
          enabled = true,
          header = [[
███╗   ██╗██╗   ██╗██╗███╗   ███╗
████╗  ██║██║   ██║██║████╗ ████║
██╔██╗ ██║██║   ██║██║██╔████╔██║
██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
        },
      },
      image = { enabled = false },
      explorer = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      notifier = { enabled = false },
      quickfile = { enabled = false },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = false },
      lazygit = { enabled = false },
    },
  },
  -- { 'nvim-tree/nvim-web-devicons', opts = {} },
}

-- vim: ts=2 sts=2 sw=2 et
