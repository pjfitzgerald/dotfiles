-- PJF: follow the current Omarchy theme instead of a hard-coded colorscheme.
--
-- `omarchy theme set <name>` stages a lazy.nvim spec at
--   ~/.local/state/omarchy/current/theme/neovim.lua
-- holding the theme's colorscheme plugin plus an inert marker entry
--   { 'LazyVim/LazyVim', opts = { colorscheme = '<name>' } }
-- Omarchy's own nvim is LazyVim; here (kickstart) we consume that same staged
-- file -- install whatever colorscheme plugin it names, then apply <name>
-- ourselves. Themes that ship no neovim.lua get an aether.nvim spec with a
-- generated palette: identical shape, handled the same way.
--
-- Live switching: a colorscheme whose plugin is already installed re-applies on
-- the next FocusGained (when you return to nvim after changing the theme).
-- Switching to a theme whose plugin is NOT installed yet needs one `:Lazy sync`
-- + restart; instant thereafter.

local staged = vim.fn.resolve(vim.fn.expand '~/.local/state/omarchy/current/theme/neovim.lua')

local function read_spec()
  if vim.fn.filereadable(staged) == 0 then
    return {}
  end
  local ok, spec = pcall(dofile, staged)
  return (ok and type(spec) == 'table') and spec or {}
end

local function colorscheme_name(spec)
  for _, p in ipairs(spec) do
    if p[1] == 'LazyVim/LazyVim' and p.opts and p.opts.colorscheme then
      return p.opts.colorscheme
    end
  end
end

-- Apply the Omarchy colorscheme, falling back to the themes kickstart still
-- bundles so nvim never lands on the bare default.
local function apply()
  local name = colorscheme_name(read_spec())
  for _, cs in ipairs { name, 'bamboo', 'tokyonight-night' } do
    if cs and pcall(vim.cmd.colorscheme, cs) then
      return
    end
  end
end

-- Re-apply when returning to nvim after `omarchy theme set` rewrote the file.
do
  local function mtime()
    local st = vim.uv.fs_stat(staged)
    return st and st.mtime.sec or 0
  end
  local last = mtime()
  vim.api.nvim_create_autocmd({ 'FocusGained', 'VimResume' }, {
    desc = 'Re-apply Omarchy colorscheme if the theme changed',
    callback = function()
      local now = mtime()
      if now == last then
        return
      end
      last = now
      -- aether backs several Omarchy themes; re-run its setup so a palette-only
      -- switch (same plugin, new colours) actually takes effect.
      for _, p in ipairs(read_spec()) do
        if (p.name == 'aether' or p[1] == 'bjarneo/aether.nvim') and p.opts then
          pcall(function()
            require('aether').setup(p.opts)
          end)
        end
      end
      apply()
    end,
  })
end

-- Belt-and-braces: apply once everything is loaded, in case the staged file had
-- no colorscheme-plugin entry to hang the config callback on.
vim.api.nvim_create_autocmd('User', { pattern = 'VeryLazy', once = true, callback = apply })

local function main_module(entry)
  if entry.main then
    return entry.main
  end
  if entry.name then
    return entry.name
  end
  local repo = entry[1]:match '([^/]+)$' or entry[1]
  return (repo:gsub('%.n?vim$', ''))
end

-- The colorscheme plugin(s) from the staged spec, minus the LazyVim marker.
-- Load them eagerly and early; each applies the colorscheme from its config.
local plugins = {}
for _, entry in ipairs(read_spec()) do
  if entry[1] and entry[1] ~= 'LazyVim/LazyVim' then
    local opts = entry.opts
    entry.opts = nil
    entry.lazy = false
    entry.priority = 1000
    entry.config = function()
      if opts and next(opts) ~= nil then
        pcall(function()
          require(main_module(entry)).setup(opts)
        end)
      end
      apply()
    end
    plugins[#plugins + 1] = entry
  end
end

return plugins
