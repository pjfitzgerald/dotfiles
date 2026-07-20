-- obsidian.nvim — community fork (obsidian-nvim/obsidian.nvim), the actively
-- maintained version. The original epwalsh/obsidian.nvim is effectively dead.
--
-- Built-in default keymaps (buffer-local in a note, no config needed):
--   <CR>      smart_action  -> follow link / toggle checkbox / fold heading
--   ]o / [o   nav_link      -> jump to next / previous link in the buffer
--
-- Everything below adds a <leader>o leader set on top of those defaults, plus
-- the vault workflow merged from the macOS config: daily-note stepping relative
-- to the current note, a <CR> strip-marker wrapper, a nav_link fix for repeated
-- links, plain-Unicode checkbox icons, and path-scoped conceallevel.

-- PJF: the PKM vault lives in a different place per machine. On WSL it's the
-- Juvare OneDrive folder; on macOS it's ~/pkm. Resolve once and reuse for the
-- workspace, the conceallevel autocmd, and the <leader>oP tmux window so the
-- same file works on both boxes.
local vault_path = vim.fn.has 'wsl' == 1 and '/mnt/c/Users/patrick.fitzgerald/OneDrive - Juvare/Documents/juvare-pkm' or vim.fn.expand '~/pkm'

-- PJF: note IDs = the title, verbatim. The plugin's default (builtin.zettel_id)
-- names the file with a random ID, so every link comes out as the ugly
-- [[1784423843-GDXI|otcom -- task archive]] id+alias form. The built-in
-- builtin.title_id isn't right either -- it slugs to lowercase-hyphenated, but
-- this vault's filenames keep spaces and case ('claude project hub note.md'). So
-- use the title as-is (minus characters that are illegal in a filename), which
-- makes links just [[otcom -- task archive]]. Falls back to a zettel id for
-- untitled notes, and appends -2, -3, ... if the name is already taken.
local function obsidian_title_id(title, dir)
  local builtin = require 'obsidian.builtin'
  if type(title) ~= 'string' then
    return builtin.zettel_id()
  end
  -- strip path separators and characters Windows/WSL reject in filenames
  local base = vim.trim((title:gsub('[/\\:%*%?"<>|]', '')))
  if base == '' then
    return builtin.zettel_id()
  end
  if not dir then
    return base
  end
  local Path = require 'obsidian.path'
  local candidate, idx = base, 2
  while (Path.new(dir) / candidate):with_suffix('.md', true):exists() do
    candidate = string.format('%s-%d', base, idx)
    idx = idx + 1
  end
  return candidate
end

-- PJF: step to the previous/next day's daily note RELATIVE TO THE CURRENT NOTE.
-- The built-in :Obsidian yesterday/tomorrow are relative to the system date, so
-- they don't "cycle" when you're already viewing an older daily note. This parses
-- the date from the current buffer's filename (YYYY-MM-DD, or the legacy YYYYMMDD)
-- and opens the day +/- `delta` away; falls back to today if not on a daily note.
-- Used by <leader>o[ / <leader>o] in the keys table below.
local function obsidian_daily_step(delta)
  local stem = vim.fn.expand '%:t:r'
  local y, m, d = stem:match '^(%d%d%d%d)%-(%d%d)%-(%d%d)$'
  if not y then
    y, m, d = stem:match '^(%d%d%d%d)(%d%d)(%d%d)$'
  end
  local anchor = y and os.time { year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 } or os.time()
  require('obsidian.daily').daily({ date = anchor + delta * 24 * 3600 }):open()
end

-- PJF: weekly notes. obsidian.nvim has no native weekly/periodic-notes feature
-- (only daily_notes), so this is a small custom impl mirroring the daily flow
-- above. Notes live in <vault>/weekly notes/ named YYYY-MM-DD_weekly_note where
-- the date is the MONDAY of that week, so both Neovim and the desktop Periodic
-- Notes plugin open/create the same files on the synced vault (match its weekly
-- format 'YYYY-MM-DD_weekly_note' + folder 'weekly notes' to interoperate).
local function obsidian_monday_of(t)
  -- Normalise to noon first so the whole-day subtraction below can't slip a day
  -- across a DST boundary.
  local parts = os.date('*t', t)
  parts.hour, parts.min, parts.sec = 12, 0, 0
  local noon = os.time(parts)
  local wday = os.date('*t', noon).wday -- 1=Sun .. 7=Sat
  local days_since_monday = (wday + 5) % 7 -- Mon(2)->0, Sun(1)->6
  return noon - days_since_monday * 24 * 3600
end

-- Open (or create) the weekly note for the week containing `datetime`.
local function obsidian_open_weekly(datetime)
  local Path = require 'obsidian.path'
  local Note = require 'obsidian.note'
  local monday = obsidian_monday_of(datetime)
  local id = os.date('%Y-%m-%d', monday) .. '_weekly_note'
  local path = Path.new(Obsidian.dir) / 'weekly notes' / (id .. '.md')
  local note
  if path:exists() then
    note = Note.from_file(path)
  else
    -- verbatim so the '_weekly_note' id isn't slugified; write() applies the
    -- vault's default frontmatter (same as a daily note), no body template.
    note = Note.create { id = id, verbatim = true, aliases = {}, tags = {}, dir = path:parent() }
    note:write()
  end
  note:open()
end

-- Used by <leader>o{ / <leader>o} to step weeks relative to the CURRENT note when
-- it's a weekly note, else relative to today (mirrors obsidian_daily_step).
local function obsidian_weekly_step(delta)
  local stem = vim.fn.expand '%:t:r'
  local y, m, d = stem:match '^(%d%d%d%d)%-(%d%d)%-(%d%d)_weekly_note$'
  local anchor = y and os.time { year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 } or os.time()
  obsidian_open_weekly(anchor + delta * 7 * 24 * 3600)
end

-- PJF: <CR> wrapper for obsidian notes. The built-in checkbox cycle (smart_action
-- + checkbox.order = {'',' ','x'}) goes bare -> '- ' dash -> [ ] -> [x] -> bare,
-- but it can't REMOVE the list marker. This adds a 'strip back to a bare line'
-- stop: on a '- [x] text' line it strips the whole '- [x] ' prefix, completing
-- the loop. Everything else -- links, headings, tags, and the rest of the cycle
-- -- delegates to the plugin's smart_action. Installed as a buffer-local <CR> map
-- in the config function below.
local function obsidian_cr()
  local api = require 'obsidian.api'
  local line = vim.api.nvim_get_current_line()
  -- '- [x]' is the last state before looping back to a bare line, so we strip the
  -- WHOLE '- [x] ' prefix here. Guard with cursor_link/cursor_tag so pressing <CR>
  -- on a link/tag inside a '- [x] ...' item still follows it.
  local indent, body = line:match '^(%s*)%- %[x%]%s?(.*)$'
  if indent and not api.cursor_link() and not api.cursor_tag() then
    vim.api.nvim_set_current_line(indent .. body)
    return
  end
  -- otherwise defer to the plugin: smart_action returns keys to feed (noremap, so
  -- a returned literal '<CR>' runs the default action and never recurses into this)
  local keys = api.smart_action()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', false)
end

-- PJF: visual-mode counterpart to obsidian_cr. Applies the same short-cycle
-- checkbox toggle (bare -> '- ' dash -> [ ] -> [x] -> bare) to every line in
-- the visual selection instead of just the cursor line. The plugin's own
-- toggle_checkbox (used by <leader>oc) already loops over a visual range, but
-- like smart_action it can't remove the list marker -- it only cycles
-- '- [x]' back to a '- ' dash, not all the way to bare. So per line we check
-- for '- [x]' first and strip the whole prefix ourselves, same as
-- obsidian_cr, and otherwise fall back to the plugin's own per-line toggle
-- (actions._toggle_checkbox) for the bare/dash/[ ] steps.
--
-- Deliberately reads the range with line('v')/line('.') instead of
-- obsidian.api.get_visual_selection, which feedkeys an <Esc> and drops the
-- selection -- that made <CR> a one-shot action requiring reselection to
-- cycle again. Left untouched (no <Esc>, no cursor move), Neovim keeps the
-- visual selection active after the callback returns, so <CR> can be pressed
-- repeatedly to keep cycling the same lines through the states.
local function obsidian_cr_visual()
  local actions = require 'obsidian.actions'
  local start_lnum, end_lnum = vim.fn.line 'v', vim.fn.line '.'
  if start_lnum > end_lnum then
    start_lnum, end_lnum = end_lnum, start_lnum
  end
  local order = Obsidian.opts.checkbox.order
  for lnum = start_lnum, end_lnum do
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
    if line then
      local indent, body = line:match '^(%s*)%- %[x%]%s?(.*)$'
      if indent then
        vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, true, { indent .. body })
      elseif line:match '%S' or Obsidian.opts.checkbox.create_new then
        actions._toggle_checkbox(order, lnum)
      end
    end
  end
end

return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- always use the latest release
  ft = 'markdown',
  cmd = 'Obsidian',
  -- PJF: the plugin hardcodes its bullet-conceal to match '-', '*' AND '+'
  -- (ui.lua: `"^%s*[-%*%+] "`), with no config knob, so '*' and '+' list markers
  -- also render as '•'. Patch the marker class down to '-' only so '*' and '+'
  -- stay literal. Runs on install and re-applies after every :Lazy update (the
  -- git pull resets ui.lua, then build re-patches). A Lua function rather than a
  -- shell string: it's cross-platform, and lazy.nvim routes any build string
  -- ending in `.lua` to its "load a Lua file" branch instead of the shell.
  -- Idempotent — matches the upstream class `[-%*%+]` or a half-patched `[-%*]`.
  build = function(plugin)
    local path = plugin.dir .. '/lua/obsidian/ui.lua'
    local f = io.open(path, 'r')
    if not f then
      return
    end
    local content = f:read '*a'
    f:close()
    local patched = content:gsub('%[%-%%%*%%%+%]', '[-]'):gsub('%[%-%%%*%]', '[-]')
    if patched ~= content then
      local w = io.open(path, 'w')
      if w then
        w:write(patched)
        w:close()
      end
    end
  end,
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  -- PJF: always-on bits that shouldn't wait for the plugin to lazy-load. `init`
  -- runs at startup for every plugin regardless of lazy-loading.
  init = function()
    -- open the pkm vault in a NEW tmux window (named 'pkm', cwd = vault, running
    -- nvim on the vault). A new window beats a pane (cramped for a whole vault) or
    -- a session (overkill) -- pkm gets full-screen space and `prefix + l` flips
    -- back. Mirrors `prefix + P` on the tmux side.
    vim.keymap.set('n', '<leader>oP', function()
      if vim.env.TMUX == nil then
        return vim.notify('Not inside tmux — cannot open a tmux window', vim.log.levels.WARN)
      end
      vim.fn.system { 'tmux', 'new-window', '-n', 'pkm', '-c', vault_path, 'nvim', vault_path }
    end, { desc = 'Obsidian: open pkm vault in new tmux window' })

    -- enable conceal only inside the pkm vault so obsidian.nvim's UI features
    -- render there, without concealing JSON/other filetypes across other projects.
    -- conceallevel is window-local, so set it on every event that shows a vault
    -- note in a window (initial read, new split, tmux-resurrect-restored windows).
    -- Match by path prefix inside the callback rather than an autocmd `pattern`
    -- glob, since the WSL vault path contains spaces.
    vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWinEnter' }, {
      pattern = '*.md',
      callback = function(ev)
        if vim.api.nvim_buf_get_name(ev.buf):sub(1, #vault_path) == vault_path then
          vim.opt_local.conceallevel = 2
        end
      end,
    })
  end,
  -- Global keymaps: these also lazy-load the plugin on first press.
  keys = {
    -- open / find / create
    { '<leader>oo', '<cmd>Obsidian quick_switch<cr>', desc = 'Obsidian: open/switch note' },
    { '<leader>on', '<cmd>Obsidian new<cr>', desc = 'Obsidian: new note' },
    { '<leader>os', '<cmd>Obsidian search<cr>', desc = 'Obsidian: search (grep)' },
    { '<leader>og', '<cmd>Obsidian tags<cr>', desc = 'Obsidian: find by tag' },
    -- daily notes
    { '<leader>ot', '<cmd>Obsidian today<cr>', desc = 'Obsidian: today' },
    { '<leader>oy', '<cmd>Obsidian yesterday<cr>', desc = 'Obsidian: yesterday' },
    { '<leader>om', '<cmd>Obsidian tomorrow<cr>', desc = 'Obsidian: tomorrow' },
    { '<leader>od', '<cmd>Obsidian dailies<cr>', desc = 'Obsidian: browse dailies' },
    -- cycle daily notes relative to the CURRENT note (older/newer day)
    {
      '<leader>o[',
      function()
        obsidian_daily_step(-1)
      end,
      desc = 'Obsidian: previous day note',
    },
    {
      '<leader>o]',
      function()
        obsidian_daily_step(1)
      end,
      desc = 'Obsidian: next day note',
    },
    -- weekly notes (custom; see obsidian_open_weekly). Monday-anchored,
    -- <vault>/weekly notes/YYYY-MM-DD_weekly_note.md. Braces step weeks,
    -- paralleling the brackets that step days above.
    {
      '<leader>ow',
      function()
        obsidian_open_weekly(os.time())
      end,
      desc = 'Obsidian: this week',
    },
    {
      '<leader>o{',
      function()
        obsidian_weekly_step(-1)
      end,
      desc = 'Obsidian: previous week note',
    },
    {
      '<leader>o}',
      function()
        obsidian_weekly_step(1)
      end,
      desc = 'Obsidian: next week note',
    },
    -- navigation within / around a note
    { '<leader>ob', '<cmd>Obsidian backlinks<cr>', desc = 'Obsidian: backlinks' },
    { '<leader>ol', '<cmd>Obsidian links<cr>', desc = 'Obsidian: links in note' },
    { '<leader>ox', '<cmd>Obsidian toc<cr>', desc = 'Obsidian: table of contents' },
    -- follow the link under cursor into a split ('<CR>' follows in place)
    { '<leader>ov', '<cmd>Obsidian follow_link vsplit<cr>', desc = 'Obsidian: follow link in vsplit' },
    { '<leader>oh', '<cmd>Obsidian follow_link hsplit<cr>', desc = 'Obsidian: follow link in hsplit' },
    -- editing. <CR> (built-in smart action) cycles the SHORT set via checkbox.order
    -- below: bare -> dash -> [ ] -> [x]. <leader>oc cycles the FULL set of statuses
    -- by temporarily swapping in the longer order list.
    {
      '<leader>oc',
      function()
        local cfg = Obsidian.opts.checkbox
        local saved = cfg.order
        cfg.order = { ' ', 'x', '~', '!', '>', '' }
        pcall(require('obsidian.actions').toggle_checkbox)
        cfg.order = saved
      end,
      mode = { 'n', 'v' },
      desc = 'Obsidian: cycle all checkbox statuses',
    },
    { '<leader>oT', '<cmd>Obsidian template<cr>', desc = 'Obsidian: insert template' },
    { '<leader>oi', '<cmd>Obsidian paste_img<cr>', desc = 'Obsidian: paste image' },
    { '<leader>or', '<cmd>Obsidian rename<cr>', desc = 'Obsidian: rename + fix links' },
    -- visual-mode: extract / link a selection
    { '<leader>oe', '<cmd>Obsidian extract_note<cr>', mode = 'v', desc = 'Obsidian: extract selection to note' },
    { '<leader>ok', '<cmd>Obsidian link<cr>', mode = 'v', desc = 'Obsidian: link selection' },
  },
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- use modern `:Obsidian <subcommand>` syntax only
    -- PJF: filename == title, so wiki links render as plain [[note name]] with no
    -- unique-id + alias. See obsidian_title_id above.
    note_id_func = obsidian_title_id,
    workspaces = {
      { name = 'pkm', path = vault_path },
    },
    -- PJF: daily notes -> <vault>/daily notes/YYYY-MM-DD.md (:Obsidian today/etc).
    -- Existing history in that folder uses YYYYMMDD; new ones use YYYY-MM-DD.
    -- workdays_only defaults to true, which makes :Obsidian yesterday/tomorrow skip
    -- weekends (e.g. Monday's "yesterday" = Friday); set false for literal calendar
    -- days, matching <leader>o[ / <leader>o] which always step +/-1 day.
    daily_notes = {
      folder = 'daily notes',
      date_format = 'YYYY-MM-DD',
      workdays_only = false,
    },
    -- PJF: <CR> checkbox cycle (dash first). '' is the plain '- ' dash and is
    -- order[1], so a bare line becomes a dash before a checkbox. Combined with the
    -- obsidian_cr wrapper (strips '- [x]' back to a bare line), the full loop is:
    -- bare -> '- ' dash -> [ ] -> [x] -> bare. The full set of statuses is reachable
    -- via <leader>oc (see keys table above).
    checkbox = {
      order = { '', ' ', 'x' },
    },
    -- PJF: silence the spurious "conceallevel set to 0" warning. Our autocmd (in
    -- `init` above) sets conceallevel=2 for vault files, but obsidian's BufEnter
    -- check can still fire transiently in a tmux-resurrect-restored window before it
    -- runs. Custom checkbox icons are applied post-setup (see config below) rather
    -- than via ui.checkboxes, which would warn about ordering on launch.
    ui = {
      ignore_conceal_warn = true,
    },
  },
  config = function(_, opts)
    require('obsidian').setup(opts)
    -- Plain-Unicode checkbox icons (render without a Nerd Font). Set here, after
    -- setup, so passing `ui.checkboxes` through setup() doesn't trigger the
    -- "ui.checkboxes no longer affects ordering" warning on every launch. The
    -- renderer reads Obsidian.opts.ui live, so these take effect. Colors (hl_group)
    -- and cycle order (checkbox.order) are left untouched.
    local cb = Obsidian.opts.ui.checkboxes
    cb[' '].char, cb['x'].char = '☐', '✓'
    cb['~'].char, cb['!'].char, cb['>'].char = '✗', '!', '→'

    -- PJF: fix ]o / [o link navigation. Upstream's Note:links() (via
    -- search.find_links) dedupes matches by link *text*, so the 2nd+ time a link
    -- string repeats in a buffer it's dropped from the nav list. Result: pressing
    -- ]o/[o on a line whose links all appear earlier (e.g. a summary line repeating
    -- [[TLS]]/[[DNS]]/[[caddy]]) skips right over them. We replace actions.nav_link
    -- (which api.nav_link, and thus ]o/[o, resolve to at call time) with a version
    -- that lists every link occurrence by position. Logic mirrors upstream
    -- otherwise: per-line find_refs with the same excludes, cursor set to
    -- {line, col} so it lands on the link itself.
    require('obsidian.actions').nav_link = function(direction)
      local search = require 'obsidian.search'
      local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
      local matches = {}
      for lnum, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
        for _, ref in ipairs(search.find_refs(line, { exclude = { 'BlockID', 'Tag' } })) do
          matches[#matches + 1] = { line = lnum, start = ref[1] - 1 }
        end
      end
      if direction == 'next' then
        for i = 1, #matches do
          local m = matches[i]
          if (m.line > cursor_line) or (m.line == cursor_line and cursor_col < m.start) then
            return vim.api.nvim_win_set_cursor(0, { m.line, m.start })
          end
        end
      elseif direction == 'prev' then
        for i = #matches, 1, -1 do
          local m = matches[i]
          if (m.line < cursor_line) or (m.line == cursor_line and cursor_col > m.start) then
            return vim.api.nvim_win_set_cursor(0, { m.line, m.start })
          end
        end
      end
    end

    -- PJF: override <CR> in vault buffers with our wrapper (adds the strip-marker
    -- step; see obsidian_cr). Hooked on the plugin's own User ObsidianNoteEnter
    -- event, which fires AFTER it has claimed the buffer and installed its own
    -- <CR> smart-action map — so our override always lands last and can't race
    -- the attach. (The previous BufEnter + vim.schedule + b:obsidian_buffer
    -- check ran before the plugin's async attach on first open, so freshly
    -- opened notes silently got no wrapper maps — normal <CR> fell back to the
    -- plugin's map and looked fine, but visual <CR> did nothing.)
    vim.api.nvim_create_autocmd('User', {
      pattern = 'ObsidianNoteEnter',
      callback = function(ev)
        vim.keymap.set('n', '<CR>', obsidian_cr, { buffer = ev.buf, desc = 'Obsidian smart action (+ strip-marker cycle)' })
        vim.keymap.set('v', '<CR>', obsidian_cr_visual, { buffer = ev.buf, desc = 'Obsidian: cycle checkbox status (visual)' })
      end,
    })
  end,
}
