// Writes this pane's OpenCode state to tmux pane options, for the agent overview
// (C-Space a, tmux/.config/tmux/scripts/agents.sh). Same contract as the Claude
// Code hook ~/.claude/hooks/agent-status.sh: @agent_status, @agent_status_at.
//
// Runs in the per-pane TUI client (the server is shared by every pane, and has
// no TMUX_PANE). The event stream is global, so it only tracks the sessions this
// pane has shown, and ignores subagent (child) sessions.
import { execFile, execFileSync } from "node:child_process"
import { appendFileSync } from "node:fs"
import { type Entry, mostUrgent, type OcEvent, sessionOf, toState } from "./state.ts"

const pane = process.env.TMUX_PANE
const debug = process.env.OC_AGENT_STATUS_DEBUG

function log(line: string) {
  if (!debug) return
  try {
    appendFileSync("/tmp/oc-agent-status.log", `${new Date().toISOString().slice(11, 23)} ${pane} ${line}\n`)
  } catch {}
}

const now = () => Math.floor(Date.now() / 1000)

export default {
  id: "mahadia.agent-status",
  async setup(ctx: any) {
    if (!pane) return

    const startedAt = now()
    const sessions = new Map<string, Entry>() // this pane's root sessions
    const children = new Set<string>()
    let written = ""
    let visible: string | undefined // the session on screen in this pane
    let focused = true // just launched here, so presumably looked at

    const isChild = (id: string) => {
      if (children.has(id)) return true
      try {
        const root = ctx.data.session.root(id)
        return typeof root === "string" && root !== id
      } catch {
        return false
      }
    }

    // Write the pane's state, only when it changed. With no sessions yet (home
    // screen) the pane is idle, like Claude Code after SessionStart.
    const sync = () => {
      const top = mostUrgent([...sessions.values()]) ?? { state: "idle", at: startedAt }
      const key = `${top.state}@${top.at}`
      if (key === written) return
      written = key
      log(`write ${key} (${sessions.size} sessions)`)
      execFile("tmux", [
        "set-option", "-p", "-t", pane, "@agent_status", top.state, ";",
        "set-option", "-p", "-t", pane, "@agent_status_at", String(top.at),
      ], () => {})
    }

    // A session becomes this pane's once it's shown here. Seed its state from
    // the synced data, since it may have been running before we saw any event.
    const adopt = (id: string) => {
      if (sessions.has(id) || isChild(id)) return
      const running = ctx.data.session.status?.(id) === "running"
      sessions.set(id, { state: running ? "working" : "idle", at: now() })
      log(`adopt ${id} running=${running}`)
    }

    // "Seen" = on screen while the terminal has focus. OpenCode's session.viewed
    // only means "rendered", which also happens in a background tmux pane.
    // Only done -> idle: looking at a waiting session isn't answering it. Keeps
    // `at`, so the age is the time since it finished (same as the Claude hook).
    const markSeen = () => {
      const entry = visible ? sessions.get(visible) : undefined
      if (!focused || !visible || entry?.state !== "done") return
      sessions.set(visible, { state: "idle", at: entry.at })
      log(`seen ${visible} -> idle`)
      sync()
    }

    // tmux forwards pane focus to the terminal (focus-events on).
    try {
      ctx.renderer.on("focus", () => {
        focused = true
        log("focus")
        markSeen()
      })
      ctx.renderer.on("blur", () => {
        focused = false
        log("blur")
      })
    } catch (error) {
      log(`focus tracking unavailable: ${error}`)
    }

    const watchRoute = () => {
      try {
        const route = ctx.ui?.router?.current?.()
        visible = route?.type === "session" ? route.sessionID : undefined
        if (visible) adopt(visible)
        markSeen() // switching tabs while focused
        sync()
      } catch (error) {
        log(`route failed: ${error}`)
      }
    }
    watchRoute()
    setInterval(watchRoute, 500).unref?.()

    const handle = (event: OcEvent) => {
      const id = sessionOf(event)
      if (!id) return
      if (event.type === "session.created" && event.data?.parentID) children.add(id)
      if (event.type === "session.deleted") sessions.delete(id)
      if (!sessions.has(id)) return

      const state = toState(event)
      if (!state) return
      sessions.set(id, { state, at: Math.floor((event.created ?? Date.now()) / 1000) })
      log(`${event.type} ${id} -> ${state}`)
      sync()
    }

    // The stream can end when the service restarts; resubscribe.
    const listen = async () => {
      for (;;) {
        try {
          for await (const event of ctx.client.event.subscribe()) handle(event)
          log("stream ended")
        } catch (error) {
          log(`stream error: ${error}`)
        }
        await new Promise((resolve) => setTimeout(resolve, 1000))
      }
    }
    listen()

    // Clear the row when OpenCode quits. Must be sync: async work doesn't run on exit.
    process.on("exit", () => {
      try {
        execFileSync("tmux", [
          "set-option", "-p", "-u", "-t", pane, "@agent_status", ";",
          "set-option", "-p", "-u", "-t", pane, "@agent_status_at",
        ], { stdio: "ignore" })
      } catch {}
    })
  },
}
