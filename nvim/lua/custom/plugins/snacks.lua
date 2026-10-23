-- PJF: Snacks.nvim, added back for the lualine profiler-status segment (and
-- Snacks.util.color(), used by several segments in custom/plugins/lualine.lua)
-- -- ported from Omarchy's LazyVim (lazyvim/plugins/init.lua). Minimal opts:
-- this repo only needs the library functions the statusline segments call,
-- not Snacks' own dashboard/picker/notifier features.
return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {},
    config = function(_, opts)
      local notify = vim.notify
      require('snacks').setup(opts)
      -- Snacks briefly takes over vim.notify during setup; hand it back so
      -- noice.nvim (custom/plugins/noice.lua) ends up owning it, not Snacks.
      vim.notify = notify
    end,
  },
}
