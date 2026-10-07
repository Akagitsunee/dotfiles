-- Seamless Ctrl+h/j/k/l navigation between nvim splits and tmux panes.
-- The tmux half is the `christoomey/vim-tmux-navigator` TPM plugin (tmux/tmux.conf); it
-- only forwards the keys to nvim when the pane is running nvim, so both halves are needed.
return {
  {
    'christoomey/vim-tmux-navigator',
    cmd = { 'TmuxNavigateLeft', 'TmuxNavigateDown', 'TmuxNavigateUp', 'TmuxNavigateRight', 'TmuxNavigatePrevious' },
    init = function()
      -- Mappings are declared through `keys` below (lazy-loading + which-key descriptions).
      vim.g.tmux_navigator_no_mappings = 1
    end,
    keys = {
      { '<C-h>', '<cmd>TmuxNavigateLeft<cr>', desc = 'Focus left (nvim split / tmux pane)' },
      { '<C-j>', '<cmd>TmuxNavigateDown<cr>', desc = 'Focus down (nvim split / tmux pane)' },
      { '<C-k>', '<cmd>TmuxNavigateUp<cr>', desc = 'Focus up (nvim split / tmux pane)' },
      { '<C-l>', '<cmd>TmuxNavigateRight<cr>', desc = 'Focus right (nvim split / tmux pane)' },
      { '<C-\\>', '<cmd>TmuxNavigatePrevious<cr>', desc = 'Focus previous (nvim split / tmux pane)' },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
