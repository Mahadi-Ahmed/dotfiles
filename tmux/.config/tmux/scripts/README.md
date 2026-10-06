# tmux scripts

| Script | Used by | What it does |
|---|---|---|
| `git-repo-name.sh` | status line, `agents.sh` | Prints the git repo name for a directory |
| `agents.sh` | `agents-picker.sh` | Lists every Claude Code session running in tmux, with its state |
| `agents-picker.sh` | `C-Space a` | fzf popup over `agents.sh`; `enter` jumps to the agent's pane |

The rest of this file covers the **agent overview** (`agents.sh` + `agents-picker.sh`).

---

## Agent overview

`C-Space a` opens a popup listing every Claude Code session across all tmux sessions, sorted by urgency:

| State | Meaning |
|---|---|
| **waiting** | Needs you: permission prompt or a question |
| **done** | Finished, and you haven't looked at it yet |
| **working** | Busy |
| **idle** | Open, nothing to do (or done and already seen) |

`j`/`k` move, `enter` jumps to the pane, `/` filters, `q`/`esc` quits.

### How it works

Claude Code hooks write the state onto the agent's own tmux pane as pane options (`@agent_status`, `@agent_status_at`). `agents.sh` reads those options from all panes. Nothing is written to disk and there's no daemon or polling.

```
Claude hook ──► agent-status.sh <state> ──► tmux pane option on $TMUX_PANE
                                                     │
C-Space a ──► agents-picker.sh ──► agents.sh ◄───────┘  (tmux list-panes -a)
                    │
                    └─► fzf ──► tmux switch-client -t %<pane_id>
```

---

## Setup

### Requirements

- tmux with `focus-events on` (already set in `tmux.conf`)
- fzf ≥ 0.59 (for `--no-input` / `show-input` / `$FZF_INPUT_STATE`)
- Claude Code must be **started inside a tmux pane**. The hook relies on `$TMUX_PANE`, so sessions started outside tmux are ignored.

### 1. tmux side

Stowing `tmux` is enough. `tmux.conf` already contains:

```tmux
set-hook -g pane-focus-in 'if-shell -F "#{==:#{@agent_status},done}" "set-option -p @agent_status idle"'

bind -N "agent overview" a display-popup -E -w 80% -h 60% "~/.config/tmux/scripts/agents-picker.sh"
```

Reload with `prefix r`.

### 2. Hook script: `~/.claude/hooks/agent-status.sh`

Save this as `~/.claude/hooks/agent-status.sh`:

```sh
#!/bin/sh
# Claude Code hook: records this agent's state on its tmux pane so
# ~/.config/tmux/scripts/agents.sh can list it.
#
# Usage (from settings.json): agent-status.sh working|waiting|done|idle|clear
# Sets pane options @agent_status and @agent_status_at (epoch seconds) on
# $TMUX_PANE; "clear" unsets both. Must never print to stdout or exit non-zero.

if [ -z "$TMUX_PANE" ]; then
  exit 0
fi

if [ "$1" = clear ]; then
  tmux set-option -p -u -t "$TMUX_PANE" @agent_status 2>/dev/null
  tmux set-option -p -u -t "$TMUX_PANE" @agent_status_at 2>/dev/null
else
  tmux set-option -p -t "$TMUX_PANE" @agent_status "$1" 2>/dev/null
  tmux set-option -p -t "$TMUX_PANE" @agent_status_at "$(date +%s)" 2>/dev/null
fi

exit 0
```

```sh
chmod +x ~/.claude/hooks/agent-status.sh
```

Rules this script must keep:

- **Never print to stdout.** `UserPromptSubmit` hook output is injected into the model's context.
- **Always exit 0.** Exit code 2 means "block": on `Stop` it keeps Claude going, on `UserPromptSubmit` it rejects your prompt.
- **The state comes from `$1`**, not from the JSON on stdin. The matchers in `settings.json` do the filtering, so no `jq` is needed.

### 3. Register the hooks: `~/.claude/settings.json`

Add these seven events under `"hooks"`. If you already have hooks (e.g. `PreToolUse`), **merge** these next to them; don't replace the whole `hooks` object.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/agent-status.sh idle" }]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/agent-status.sh working" }]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/agent-status.sh working" }]
      }
    ],
    "PostToolUseFailure": [
      {
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/agent-status.sh working" }]
      }
    ],
    "Notification": [
      {
        "matcher": "permission_prompt|elicitation_dialog",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/agent-status.sh waiting" }]
      }
    ],
    "Stop": [
      {
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/agent-status.sh done" }]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/agent-status.sh clear" }]
      }
    ]
  }
}
```

What each event does:

| Event | Matcher | State | Why |
|---|---|---|---|
| `SessionStart` | `startup\|resume\|clear` | idle | The session shows up as soon as Claude opens. `compact` is left out on purpose: auto-compaction happens mid-turn |
| `UserPromptSubmit` | – | working | You sent a prompt |
| `PostToolUse` | – | working | Moves **waiting → working** once you approve/deny/answer. Also refreshes the age |
| `PostToolUseFailure` | – | working | Same, when the tool failed or was denied |
| `Notification` | `permission_prompt\|elicitation_dialog` | waiting | Permission prompts and questions (`AskUserQuestion` also sends `permission_prompt`) |
| `Stop` | – | done | Turn finished. tmux turns it into idle when you focus the pane |
| `SessionEnd` | – | *clear* | The row disappears |

`Notification:idle_prompt` is **not** used. It fires ~60s after `Stop` and would turn every **done** into **waiting**.

Validate after editing. Claude Code hot-reloads hooks into running sessions, and an invalid file silently disables **all** hooks:

```sh
jq empty ~/.claude/settings.json && jq '.hooks | keys' ~/.claude/settings.json
```

### 4. Try it

1. Start `claude` in a tmux pane.
2. `C-Space a` should show it as **idle**.
3. Send a prompt: **working**. When it finishes: **done**. Focus the pane: **idle**.

---

## Known behaviour

- **Esc interrupt keeps the previous state** (often **waiting** if you escaped a dialog). No hook fires on interrupt. The next prompt resets it.
- **A pane you're looking at when it finishes stays done** until you leave and come back (`pane-focus-in` only fires on arrival).
- **The working age is time since the last tool call**, not since the prompt. A large age on a working row suggests a stuck agent.

---

## Debugging

| Symptom | Check |
|---|---|
| Agent missing from the list | `tmux show-options -p -t %<id> \| grep agent`. Empty means the hooks didn't run for that pane |
| | Inside Claude: `!echo $TMUX_PANE`. Empty means Claude wasn't started inside tmux |
| | `jq empty ~/.claude/settings.json`. Invalid JSON = no hooks at all |
| Test the hook by hand | `echo '{}' \| TMUX_PANE=%<id> ~/.claude/hooks/agent-status.sh waiting; echo $?` then run `agents.sh`. Expect a row, exit 0, no output |
| `C-Space a` does nothing | `tmux list-keys -N \| grep agent`. Missing = `prefix r` |
| Popup errors | Run `~/.config/tmux/scripts/agents-picker.sh` directly in a pane |
| Wrong columns | `~/.config/tmux/scripts/agents.sh \| cat -A`. Expect a tab before the pane id |
| Reset one pane | `tmux set-option -p -u -t %<id> @agent_status` |

---

## Uninstall

1. Remove the seven events from `settings.json` (keep any other hooks), then `jq empty` it.
2. `rm ~/.claude/hooks/agent-status.sh`
3. Remove the `pane-focus-in` hook and the `a` binding from `tmux.conf`, then `tmux set-hook -gu pane-focus-in; tmux unbind a`.
4. Delete `agents.sh` and `agents-picker.sh`.

Pane options disappear with their panes; nothing stays on disk.
