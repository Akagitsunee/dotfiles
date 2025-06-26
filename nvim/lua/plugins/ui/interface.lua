return {
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function(_, opts)
      require('which-key').setup(opts)
    end,
    opts = {
      preset = 'helix',
      -- 🎨 Use settings from the global design system
      win = {
        border = _G.config.ui.border, -- "rounded", "single", etc.
        wo = { winblend = _G.config.ui.winblend },
      },
      sort = { 'manual', 'local', 'order', 'group', 'alphanum', 'mod' },
      -- Your custom key specifications, now using global icons
      spec = {
        {
          mode = { 'n', 'v' },
          -- Groups with symbols from _G.config.icons.groups
          { '<leader>a', group = 'AI', icon = _G.config.icons.groups.ai },
          { '<leader>c', group = 'Code', icon = _G.config.icons.groups.code },
          { '<leader>d', group = 'Debug', icon = _G.config.icons.groups.debug },
          { '<leader>f', group = 'Find', icon = _G.config.icons.groups.find },
          { '<leader>g', group = 'Git', icon = _G.config.icons.groups.git },
          { '<leader>l', group = 'Lazy', icon = _G.config.icons.groups.lazy },
          { '<leader>p', group = 'Paste/Project', icon = _G.config.icons.groups.paste_project },
          { '<leader>q', group = 'Quit', icon = _G.config.icons.groups.quit },
          { '<leader>s', group = 'Search', icon = _G.config.icons.groups.search },
          { '<leader>t', group = 'פText', icon = _G.config.icons.groups.text },
          { '<leader>u', group = 'UI', icon = _G.config.icons.groups.ui },
          { '<leader>x', group = 'Trouble', icon = _G.config.icons.groups.trouble },

          {
            '<leader>b',
            group = 'buffer',
            icon = { icon = _G.config.icons.groups.buffer, color = 'blue' },
            expand = function()
              return require('which-key.extras').expand.buf()
            end,
          },
          {
            '<leader>w',
            group = 'windows',
            icon = { icon = _G.config.icons.groups.windows, color = 'cyan' },
            proxy = '<c-w>',
            expand = function()
              return require('which-key.extras').expand.win()
            end,
          },

          -- Navigation groups
          { '[', group = 'prev', icon = { icon = _G.config.icons.groups.prev, color = 'blue' } },
          { ']', group = 'next', icon = { icon = _G.config.icons.groups.next, color = 'blue' } },
          { 'g', group = 'goto', icon = { icon = _G.config.icons.groups.go_to, color = 'cyan' } },
          { 'gs', group = 'surround', icon = { icon = _G.config.icons.groups.surround, color = 'yellow' } },
          { 'z', group = 'fold', icon = { icon = _G.config.icons.groups.fold, color = 'purple' } },

          -- Descriptions
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
          header = [[⠀⠀⠀⠀⠀⢀⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣸⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢠⡟⠘⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢰⡟⠀⠀⠈⠻⣷⣤⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣠⡟⠀⠀⠀⠀⠀⠈⢻⡿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⣰⡟⠀⠀⠀⠀⠀⠀⠀⠀⠻⠸⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢰⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣇⠀⣠⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⠀⠀⠀⠀⠀⠀⠀
⣾⡁⢀⣠⠴⠒⠲⣤⣠⠶⠋⠳⣤⣸⣿⣰⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀
⣿⠟⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⣽⠏⣿⡿⢿⣿⣿⣿⣷⣄⠀⠀⠀⠀⢠⣾⣿⣿⣿⠋⢹⡇⠀⠀⠀⠀⠀⠀
⢹⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡟⠀⣿⠁⠀⠙⣿⡛⠛⢿⡶⠶⠶⠶⣿⣄⣀⣰⠃⠀⢸⡇⠀⠀⠀⠀⠀⠀
⠈⢷⡀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡿⠁⠀⣿⠀⠀⠀⠈⢷⡀⠘⠛⠀⠀⠀⠀⠈⠉⠳⣄⠀⢸⡇⠀⠀⠀⠀⠀⠀
⠀⠈⢿⣦⡀⠀⠀⠀⠀⠀⢀⣿⣇⣀⠀⢻⠀⠀⠀⠀⢰⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⣾⠃⠀⣤⣤⣄⠀⠀
⠀⠀⠀⠉⠻⢶⣄⣠⣴⠞⠛⠉⠉⠙⠻⢾⣇⠀⢀⣰⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡄⠀⣿⢩⡿⣿⡆
⠀⠀⠀⠀⣠⣴⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⢹⡷⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⣿⣟⣵⡿⠁
⠀⢀⣠⡾⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣇⠀⠀⠀⣴⣿⠀⠀⠀⠀⠀⠀⢠⣶⠀⠀⣸⡇⠀⠙⠋⠁⠀⠀
⢸⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣄⣈⣀⣙⣁⠀⠀⣶⣾⡶⠀⠻⠿⠀⢠⣿⣁⡀⠀⠀⠀⠀⠀
⠈⠛⠻⠿⠶⠶⠶⡤⣤⣤⣤⣄⣀⣤⣀⣠⣤⣀⣀⣹⣿⣿⣿⣿⣤⣽⣿⣴⣶⣶⡦⢼⣿⣿⣿⣿⠇⠀⠀⠀⠀
                                      __
                                     |  \
 _______   ______   ______  __     __ \▓▓______ ____
|       \ /      \ /      \|  \   /  \  \      \    \
| ▓▓▓▓▓▓▓\  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\\▓▓\ /  ▓▓ ▓▓ ▓▓▓▓▓▓\▓▓▓▓\
| ▓▓  | ▓▓ ▓▓    ▓▓ ▓▓  | ▓▓ \▓▓\  ▓▓| ▓▓ ▓▓ | ▓▓ | ▓▓
| ▓▓  | ▓▓ ▓▓▓▓▓▓▓▓ ▓▓__/ ▓▓  \▓▓ ▓▓ | ▓▓ ▓▓ | ▓▓ | ▓▓
| ▓▓  | ▓▓\▓▓     \\▓▓    ▓▓   \▓▓▓  | ▓▓ ▓▓ | ▓▓ | ▓▓
 \▓▓   \▓▓ \▓▓▓▓▓▓▓ \▓▓▓▓▓▓     \▓    \▓▓\▓▓  \▓▓  \▓▓
]],
        },
      },
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
  { 'nvim-tree/nvim-web-devicons', opts = {} },
}

-- vim: ts=2 sts=2 sw=2 et
