local M = {}

local PairState = {
  active = false,
  reapply_autocmd = nil,
  original = {
    scrolloff = nil,
    colorcolumn = nil,
    signcolumn = nil,
    conceallevel = nil,
    cmdheight = nil,
    showcmd = nil,
    showmode = nil,
    laststatus = nil,
    showtabline = nil,
    guicursor = nil,
    highlights = {
      CursorLine = nil,
      CursorLineNr = nil,
      LineNr = nil,
    },
  },
}

-- ─── Helpers ──────────────────────────────────────────────────────────────────

local function save_highlight(group_name)
  local hl = vim.api.nvim_get_hl(0, { name = group_name, link = false })
  PairState.original.highlights[group_name] = hl
end

local function restore_highlight(group_name)
  local hl = PairState.original.highlights[group_name]
  if hl then
    vim.api.nvim_set_hl(0, group_name, hl)
  else
    vim.api.nvim_set_hl(0, group_name, {})
  end
end

local function save_state()
  PairState.original.scrolloff   = vim.opt.scrolloff:get()
  PairState.original.colorcolumn = vim.opt.colorcolumn:get()
  PairState.original.signcolumn  = vim.opt.signcolumn:get()
  PairState.original.conceallevel = vim.opt.conceallevel:get()
  PairState.original.cmdheight   = vim.opt.cmdheight:get()
  PairState.original.showcmd     = vim.opt.showcmd:get()
  PairState.original.showmode    = vim.opt.showmode:get()
  PairState.original.laststatus  = vim.opt.laststatus:get()
  PairState.original.showtabline = vim.opt.showtabline:get()
  PairState.original.guicursor   = vim.opt.guicursor:get()

  for group_name in pairs(PairState.original.highlights) do
    save_highlight(group_name)
  end
end

local function restore_state()
  vim.opt.scrolloff    = PairState.original.scrolloff
  vim.opt.colorcolumn  = PairState.original.colorcolumn
  vim.opt.signcolumn   = PairState.original.signcolumn
  vim.opt.conceallevel = PairState.original.conceallevel
  vim.opt.cmdheight    = PairState.original.cmdheight
  vim.opt.showcmd      = PairState.original.showcmd
  vim.opt.showmode     = PairState.original.showmode
  vim.opt.laststatus   = PairState.original.laststatus
  vim.opt.showtabline  = PairState.original.showtabline
  vim.opt.guicursor    = PairState.original.guicursor

  local ln_ok, ln = pcall(require, "line-numbers")
  if ln_ok then
    ln.set_mode("relative")
  end
end

-- ─── Apply pair highlights (also called on theme change while active) ─────────

local function apply_pair_highlights()
  vim.api.nvim_set_hl(0, "PairModeCursor", { fg = "#1e1e2e", bg = "#4C7860" })
  vim.api.nvim_set_hl(0, "CursorLine",     { bg = "#2a2a2a" })
  vim.api.nvim_set_hl(0, "CursorLineNr",   { fg = "#e0def4", bold = true })
  vim.api.nvim_set_hl(0, "LineNr",         { fg = "#908caa" })
end

-- ─── Enable / Disable ─────────────────────────────────────────────────────────

local function enable_pair_mode()
  save_state()

  vim.opt.scrolloff    = 12
  vim.opt.colorcolumn  = "120"
  vim.opt.signcolumn   = "yes:2"
  vim.opt.conceallevel = 0
  vim.opt.showcmd      = true
  vim.opt.showmode     = true
  vim.opt.cmdheight    = 1
  vim.opt.laststatus   = 3

  require('lazy').load({ plugins = { 'bufferline.nvim' } })
  vim.opt.showtabline  = 2

  local ln_ok, ln = pcall(require, "line-numbers")
  if ln_ok then
    ln.set_mode("absolute")
  end

  apply_pair_highlights()

  -- Inject PairModeCursor into every guicursor entry, preserving shapes
  local new_cursor_entries = {}
  for _, entry in ipairs(PairState.original.guicursor) do
    local modes, shape = entry:match("^([^:]+):([^%-/]+)")
    if modes and shape then
      table.insert(new_cursor_entries, modes .. ":" .. shape .. "-PairModeCursor")
    else
      table.insert(new_cursor_entries, entry)
    end
  end
  vim.opt.guicursor = new_cursor_entries

  local snacks_ok, snacks = pcall(require, "snacks")
  if snacks_ok and snacks.scroll then
    snacks.scroll.enable()
  end

  -- Reapply highlights if user switches theme while pair mode is on.
  -- Uses a separate function so save_state() is NOT called again.
  PairState.reapply_autocmd = vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = apply_pair_highlights,
    desc = "Reapply pair mode highlights after theme change",
  })

  PairState.active = true
  vim.notify("Pair Programming Mode: ENABLED", vim.log.levels.INFO)
end

local function disable_pair_mode()
  restore_state()

  for group_name in pairs(PairState.original.highlights) do
    restore_highlight(group_name)
  end

  local snacks_ok, snacks = pcall(require, "snacks")
  if snacks_ok and snacks.scroll then
    snacks.scroll.disable()
  end

  if PairState.reapply_autocmd then
    vim.api.nvim_del_autocmd(PairState.reapply_autocmd)
    PairState.reapply_autocmd = nil
  end

  PairState.active = false
  vim.notify("Pair Programming Mode: DISABLED", vim.log.levels.INFO)
end

-- ─── Public API ───────────────────────────────────────────────────────────────

function M.toggle()
  if PairState.active then
    disable_pair_mode()
  else
    enable_pair_mode()
  end
end

function M.is_active()
  return PairState.active
end

function M.setup()
  vim.api.nvim_create_user_command("Pair", M.toggle, {
    desc = "Toggle Pair Programming Mode",
  })
end

return M
