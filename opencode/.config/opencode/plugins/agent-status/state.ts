// Pure state logic for the agent status plugin: OpenCode event -> dashboard
// state, and the pane's state from its sessions' states. No I/O here.

export type State = "waiting" | "done" | "working" | "idle"

// One session's state and when it entered it (epoch seconds).
export type Entry = { state: State; at: number }

// The v2 event envelope, as seen on client.event.subscribe().
export type OcEvent = { type: string; created: number; data?: any }

// The session an event belongs to. Forms carry it one level deeper.
export function sessionOf(event: OcEvent): string | undefined {
  return event.data?.sessionID ?? event.data?.form?.sessionID
}

// Map one event to the state its session is in afterwards, or null when the
// event doesn't change the state (most of the stream: tool calls, steps, usage…).
// "Seen" (done -> idle) isn't here: it depends on terminal focus, see tui.ts.
export function toState(event: OcEvent): State | null {
  switch (event.type) {
    case "session.execution.started":
    case "form.replied": // answered a question / permission prompt
    case "form.cancelled":
      return "working"
    case "form.created":
      return "waiting"
    case "session.execution.failed": // something broke: worth a look
      return "waiting"
    case "session.execution.succeeded":
      return "done"
    case "session.execution.interrupted": // Esc
      return "idle"
    default:
      return null
  }
}

const rank: Record<State, number> = { waiting: 1, done: 2, working: 3, idle: 4 }

// The state shown for the whole pane when it has several sessions (tabs): the
// most urgent one wins. Within the same state the oldest wins, matching the
// dashboard's sort: the session that has waited longest surfaces first.
// Undefined for an empty list.
export function mostUrgent(entries: Entry[]): Entry | undefined {
  let top: Entry | undefined
  for (const entry of entries) {
    if (!top || rank[entry.state] < rank[top.state] || (entry.state === top.state && entry.at < top.at)) {
      top = entry
    }
  }
  return top
}
