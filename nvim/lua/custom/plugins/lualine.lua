-- PJF: lualine.nvim, ported from Omarchy's default LazyVim statusline
-- (~/nvim-backups/lazyvim-*/share/lazy/LazyVim/lua/lazyvim/plugins/ui.lua) to
-- match its look here. `LazyVim.config.icons` / `LazyVim.lualine.root_dir()` /
-- `.pretty_path()` don't exist outside LazyVim, so those are approximated with
-- plain lualine components. Everything else -- the Snacks profiler segment,
-- noice command/mode segments, DAP status, the lazy.nvim-update indicator, and
-- the trouble.nvim symbols breadcrumb -- is ported as-is now that
-- custom/plugins/{snacks,noice,trouble}.lua and kickstart's own
-- kickstart.plugins.debug (nvim-dap) provide them.
return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = function()
      local opts = {
        options = {
          theme = 'auto',
          globalstatus = vim.o.laststatus == 3,
          disabled_filetypes = { statusline = { 'dashboard', 'alpha' } },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch' },
          lualine_c = {
            { 'diagnostics' },
            { 'filetype', icon_only = true, separator = '', padding = { left = 1, right = 0 } },
            { 'filename', path = 1 }, -- relative path -- stand-in for LazyVim.lualine.pretty_path()
          },
          lualine_x = {
            Snacks.profiler.status(),
            -- stylua: ignore
            {
              function() return require('noice').api.status.command.get() end,
              cond = function() return package.loaded['noice'] and require('noice').api.status.command.has() end,
              color = function() return { fg = Snacks.util.color 'Statement' } end,
            },
            -- stylua: ignore
            {
              function() return require('noice').api.status.mode.get() end,
              cond = function() return package.loaded['noice'] and require('noice').api.status.mode.has() end,
              color = function() return { fg = Snacks.util.color 'Constant' } end,
            },
            -- stylua: ignore
            {
              function() return '  ' .. require('dap').status() end,
              cond = function() return package.loaded['dap'] and require('dap').status() ~= '' end,
              color = function() return { fg = Snacks.util.color 'Debug' } end,
            },
            -- stylua: ignore
            {
              require('lazy.status').updates,
              cond = require('lazy.status').has_updates,
              color = function() return { fg = Snacks.util.color 'Special' } end,
            },
            {
              'diff',
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return { added = gitsigns.added, modified = gitsigns.changed, removed = gitsigns.removed }
                end
              end,
            },
          },
          lualine_y = {
            { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
            { 'location', padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function()
              return ' ' .. os.date '%R'
            end,
          },
        },
        extensions = { 'neo-tree', 'lazy', 'fzf' },
      }

      -- LSP-symbols breadcrumb, only when trouble.nvim is part of the setup
      -- (custom/plugins/trouble.lua) and not turned off for this buffer.
      if vim.g.trouble_lualine and require('lazy.core.config').plugins['trouble.nvim'] then
        local trouble = require 'trouble'
        local symbols = trouble.statusline {
          mode = 'symbols',
          groups = {},
          title = false,
          filter = { range = true },
          format = '{kind_icon}{symbol.name:Normal}',
          hl_group = 'lualine_c_normal',
        }
        table.insert(opts.sections.lualine_c, {
          symbols and symbols.get,
          cond = function()
            return vim.b.trouble_lualine ~= false and symbols.has()
          end,
        })
      end

      return opts
    end,
  },
}
