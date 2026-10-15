// Empty on purpose: all the logic lives in tui.ts.
//
// Server code runs in the shared background `opencode serve --service`, not in
// the pane. It has no $TMUX_PANE, so it can't tell which pane to update, and it
// hosts every session on the machine (work too), so a hook here would run for
// all of them.
//
// The file only exists because the loader needs a server entrypoint before it
// picks up a directory plugin's tui.ts.
export default {
  id: "mahadia.agent-status",
  async setup() {},
}
