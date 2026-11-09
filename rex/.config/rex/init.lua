-- Rex keybindings, ported from tmux/.config/tmux/tmux.conf.
--
-- C-Space is the prefix, like in tmux. Keys after it are matched by what the
-- keyboard layout types (Swedish - Pro), so tmux's " is shift+2 here and % is
-- shift+5.
--
-- Edit, then: rex config check && rex config reload

local P = "ctrl+space>"
local SHELL = "com.superlogical.terminal.shell"
local SCRIPTS = os.getenv("HOME") .. "/.config/rex/scripts"
local STATE_DIR = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/rex"

-- Directory of the pane's foreground program, so new splits and tabs open
-- where you are (tmux: -c "#{pane_current_path}")
local function pane_cwd(ctx)
  local proc = rex.call("block.method", {
    session_id = ctx.session_id,
    block_id = ctx.block_id,
    method = "process",
  })
  return proc and proc.foreground and proc.foreground.cwd or nil
end

local function shell_block(ctx)
  return { block = { flavor = SHELL, options = { cwd = pane_cwd(ctx) } } }
end

local function split(direction, side)
  return function(ctx)
    rex.call("session.new_split", {
      session_id = ctx.session_id,
      anchor_id = ctx.block_id,
      direction = direction,
      side = side,
      layout = shell_block(ctx),
      focus = true,
    })
    return true
  end
end

-- Popup like fzf-tmux -p 80%,60%
local function popup(command)
  return function(ctx)
    rex.call("session.new_layer", {
      session_id = ctx.session_id,
      bounds = { 0.1, 0.2, 0.8, 0.6 },
      layout = { block = { flavor = SHELL, label = "picker", options = { command = command } } },
      focus = true,
    })
    return true
  end
end

-- Reload
-- rex config reload has to run on the server machine, so there is no in-app
-- equivalent of tmux's prefix r

-- Prefix passthrough (tmux: bind C-Space send-prefix)
rex.bind(P .. "ctrl+space", function(ctx)
  rex.call("block.method", {
    session_id = ctx.session_id,
    block_id = ctx.block_id,
    method = "write",
    args = { data = "\0" },
  })
  return true
end)

-- Splits and tabs, in the current directory
rex.bind(P .. "shift+2", split("vertical", "after")) -- "
rex.bind(P .. "shift+5", split("horizontal", "after")) -- %
rex.bind(P .. "c", function(ctx)
  rex.call("session.new_window", { session_id = ctx.session_id, layout = shell_block(ctx) })
  return true
end)

-- Pane navigation and resizing (resize amount is a percentage of the split)
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind(P .. key, "pane.focus." .. dir)
  rex.bind(P .. "shift+" .. key, "pane.resize", { direction = dir, amount = 5 })
end

-- Kill pane, no confirm (tmux: bind-key x kill-pane). pane.close keeps a tab's
-- last pane, so close the block itself: its tab closes with it, and closing
-- the session's last pane destroys the session, like tmux
rex.bind(P .. "x", function(ctx)
  local list = rex.call("session.list_blocks", { session_id = ctx.session_id })
  local placed = 0
  for _, b in ipairs(list and list.blocks or {}) do
    if b.placement == "placed" then
      placed = placed + 1
    end
  end
  if placed <= 1 then
    rex.call("session.destroy", { session_id = ctx.session_id })
  else
    rex.call("block.close", { session_id = ctx.session_id, block_id = ctx.block_id })
  end
  return true
end)
rex.bind(P .. "z", "pane.zoom")

-- Ctrl-h/j/k/l without the prefix (tmux: vim-tmux-navigator). Panes running
-- Vim or fzf get the key, matching the plugin's is_vim check
local function is_vim(ctx)
  local proc = rex.call("block.method", {
    session_id = ctx.session_id,
    block_id = ctx.block_id,
    method = "process",
  })
  local name = proc and proc.foreground and proc.foreground.name or ""
  name = name:gsub("diff$", "")
  return name:match("^g?view$") or name:match("^g?l?n?vim?x?$") or name == "fzf"
end

for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+" .. key, function(ctx)
    if is_vim(ctx) then
      return false
    end
    rex.call("session.focus_direction", { session_id = ctx.session_id, direction = dir })
    return true
  end)
end

-- Tabs (tmux windows), numbered from 1 like base-index 1
for i = 1, 9 do
  rex.bind(P .. tostring(i), "client.tab.goto", { index = i })
end
rex.bind(P .. "n", "client.tab.next")
rex.bind(P .. "p", "client.tab.previous")
rex.bind(P .. ",", "client.tab.rename")

-- Sessions
rex.bind(P .. "shift+t", popup({ SCRIPTS .. "/rex-sesh.sh" }))
rex.bind(P .. "w", "session.switch")
rex.bind(P .. "shift+4", "session.rename") -- $

-- Last session (tmux: sesh last). rex-sesh.sh records the session it switches
-- away from, and this swaps back to it.
rex.bind(P .. "s", function(ctx)
  local file = STATE_DIR .. "/last-session"
  local f = io.open(file)
  if not f then
    return true
  end
  local last = f:read("l")
  f:close()
  if not last or last == "" or last == ctx.session_id then
    return true
  end
  local w = io.open(file, "w")
  if w then
    w:write(ctx.session_id, "\n")
    w:close()
  end
  rex.client.queue("session.select", { session_id = last })
  return true
end)

-- Command prompt
rex.bind(P .. "shift+.", "client.palette.toggle") -- :
