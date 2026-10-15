# OpenCode agent status

Puts OpenCode sessions in the tmux agent overview (`C-Space a`) next to Claude Code. It writes the same pane options as the Claude hook (`@agent_status`, `@agent_status_at`), so the overview needs no OpenCode-specific code. See [the agent overview README](../../../../../tmux/.config/tmux/scripts/README.md).

Built against OpenCode **2.0.29** (v2 plugin API).

| File | Role |
|---|---|
| `tui.ts` | Everything: picks this pane's sessions, maps events, writes tmux |
| `state.ts` | Pure logic: event → state, and the pane's state from several sessions |
| `server.ts` | Empty on purpose (see below) |

## Why it's built this way

- **Logic in `tui.ts`, not on the server.** OpenCode v2 runs one shared `opencode serve --service` (started by launchd) for every pane and project. Each `opencode` in a pane is only a client. Server plugins have no `$TMUX_PANE` and can't tell panes apart, but `tui.ts` runs in the pane's own client process.
- **`server.ts` is empty on purpose.** Server code can't tell which pane to update, and the shared service hosts every session on the machine (work too), so a hook there would run for all of them. The file only exists because the loader needs a server entrypoint (`server.ts` / `index.ts`) before it picks up a directory plugin's `tui.ts`.
- **The event stream is global.** Every client gets every session's events, so the plugin only tracks sessions it has shown in this pane.

## State model

| Event (v2) | State |
|---|---|
| plugin start, no session yet | idle |
| session first shown in this pane | working if running, else idle |
| `session.execution.started` | working |
| `form.created` (questions **and** permission prompts) | waiting |
| `form.replied` / `form.cancelled` | working |
| `session.execution.succeeded` | done |
| `session.execution.failed` | waiting (broke: worth a look) |
| `session.execution.interrupted` (Esc) | idle |
| seen: on screen **and** terminal focused | done → idle, keeps the timestamp |
| OpenCode exits | cleared |

- **Tabs:** a pane can hold several sessions. The pane shows the **most urgent** one (waiting > done > working > idle), oldest first within a state.
- **Subagents** (`parentID` on `session.created`, or `data.session.root(id) !== id`) are ignored. Otherwise a subagent finishing would mark the pane done mid-turn.
- **`session.viewed` is ignored.** It means "rendered", and fires within milliseconds of finishing even in a background tmux pane. "Seen" uses the renderer's `focus`/`blur` instead, which tmux forwards because of `focus-events on`.
- **Esc works.** Unlike Claude Code, it sets the pane to idle right away.

## Install

`setupScripts/stow.sh` does:

```sh
stow --no-folding -vt ~ opencode
```

`--no-folding` matters. When a target folder doesn't exist, stow normally *folds*: it symlinks the whole folder to the repo instead of creating it. Anything another tool then writes into it goes through the link and lands in this repo. `~/.config/opencode` is managed by the work tooling, so on a fresh machine its `opencode.json` would end up in dotfiles. With `--no-folding` stow creates real folders and links only files.

The catch: a **new or renamed file** in `agent-status/` needs a restow (`stow -R --no-folding -vt ~ opencode`). Edits to existing files don't.

Restart `opencode` in the pane to load changes. `tui.ts` is loaded by the client, so the service doesn't need a restart.

## Debugging

| Symptom | Check |
|---|---|
| Pane missing from the overview | `grep 'failed to load plugin' ~/.local/share/opencode/log/opencode.log \| tail -3` |
| | `readlink ~/.config/opencode/plugins/agent-status`. Should point into dotfiles |
| Wrong / stuck state | Start with `OC_AGENT_STATUS_DEBUG=1 opencode` and `tail -F /tmp/oc-agent-status.log`. Shows adopt, events, focus/blur, seen and every write |
| Pane option by hand | `tmux show-options -p -t %<id> \| grep agent` |

## After an OpenCode upgrade

The v2 TUI API has no published types, and the plugin relies on internals found by probing: `client.event.subscribe`, `ui.router.current`, `data.session.status/root`, and `renderer` `focus`/`blur`. If the debug log goes quiet or shows `route failed` / `stream error` / `focus tracking unavailable`, re-probe. Log `Object.keys` of the TUI `ctx` and the raw `event.type`s to a file, and compare them with the state model table.

The 1.x plugin format (named export function, `event` hook) **does not load** in v2. The loader wants `export default { id, setup }`.

## Known gaps

- Closing a tab doesn't drop its session from the pane's list until OpenCode restarts.
- Starting OpenCode assumes the terminal has focus until the first `blur`.

## Uninstall

```sh
stow -vDt ~ opencode
```

Then remove the `opencode` line from `setupScripts/stow.sh`. Pane options disappear when OpenCode exits.
