#!/usr/bin/env bash
# Rex version of the tmux `prefix T` sesh picker (tmux/.config/tmux/tmux.conf).
# Lists Rex sessions plus sesh's config and zoxide entries, then switches to
# the chosen session, creating it for a directory that has none yet.
#
# Usage: rex-sesh.sh                  open the picker
#        rex-sesh.sh list [SOURCE]    all, rex, config, zoxide or fd
#        rex-sesh.sh preview LINE
#        rex-sesh.sh kill LINE
#
# Switching sessions is a Rex.app action, so Remote Control has to be on
# (Rex.app Settings > Rex Server).

set -euo pipefail

if ! command -v rex >/dev/null 2>&1; then
  PATH="/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS:$PATH"
fi

SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/rex"
LAST_FILE="$STATE_DIR/last-session"

# Lines are "DISPLAY<TAB>KIND<TAB>TARGET". KIND is rex (TARGET is a session
# ID) or dir (TARGET is a path). fzf shows only DISPLAY.

# Label for a new session in directory $1, named the way sesh names tmux
# sessions (sesh v2 namer, default config): the main worktree's repo name plus
# the path inside it, else the directory name, with . and : as _.
# Linked worktrees are named like worktrunk's pre-start hook names their tmux
# session instead (worktrunk/.config/worktrunk/config.toml): the sanitized
# branch, which is the worktree's directory name, with . and : as -
session_label() {
  local path root="" line bare=0 name top
  local -a words
  path="$(cd "$1" 2>/dev/null && pwd -P)" || path="$1"

  top="$(git -C "$path" rev-parse --show-toplevel 2>/dev/null)" || top=""
  if [[ -n "$top" && "$(git -C "$path" rev-parse --git-dir)" == */worktrees/* ]]; then
    name="$(basename "$top" | tr '.:' '-')${path#"$top"}"
    printf '%s\n' "${name//./_}"
    return
  fi

  # The first entry of the porcelain list is the main worktree
  while IFS= read -r line; do
    if [[ -z "$line" ]]; then
      [[ -n "$root" ]] && break
      continue
    fi
    case "$line" in
    "worktree "*) root="${line#worktree }" ;;
    bare) bare=1 ;;
    esac
  done < <(git -C "$path" worktree list --porcelain 2>/dev/null)
  if ((bare)); then
    root="${root%/.bare}"
    root="${root%/.git}"
  fi

  if [[ -n "$root" ]]; then
    name="$(basename "$root")${path#"$root"}"
  else
    name="$(basename "$path")"
  fi

  name="${name//./_}"
  name="${name//:/_}"
  read -ra words <<<"$name"
  (IFS=_; printf '%s\n' "${words[*]}")
}

# Icons and colors as in `sesh list --icons`: Rex sessions get sesh's blue
# tmux icon, directories its cyan folder, config entries a gray gear
ICON_SESSION=$'\e[34m\e[39m'
ICON_DIR=$'\e[36m\e[39m'
ICON_CONFIG=$'\e[90m\e[39m'

list_rex() {
  rex ls --json | jq -r --arg icon "$ICON_SESSION" '.sessions[] | "\($icon) \(.label)\trex\t\(.session_id)"'
}

list_sesh() {
  sesh list "$@" --json |
    jq -r --arg dir "$ICON_DIR" --arg config "$ICON_CONFIG" \
      '.[] | "\(if .Src == "config" then $config else $dir end) \(.Name)\tdir\t\(.Path)"'
}

list_fd() {
  fd -H -d 2 -t d -E .Trash . ~ | while IFS= read -r dir; do
    dir="${dir%/}"
    printf '%s %s\tdir\t%s\n' "$ICON_DIR" "${dir/#$HOME/~}" "$dir"
  done
}

list() {
  case "${1:-all}" in
  all) list_rex; list_sesh -c -z ;;
  rex) list_rex ;;
  config) list_sesh -c ;;
  zoxide) list_sesh -z ;;
  fd) list_fd ;;
  esac
}

preview() {
  local kind target
  IFS=$'\t' read -r _ kind target <<<"$1"
  if [[ "$kind" == rex && "$target" == "${REX_SESSION:-}" ]]; then
    # Capturing this session would show the picker itself
    echo "Current session"
  elif [[ "$kind" == rex ]]; then
    rex capture -s "$target" --trim | tail -n 80
  else
    eza -la --icons --color=always "$target" 2>/dev/null || ls -la "$target"
  fi
}

kill_session() {
  local kind target
  IFS=$'\t' read -r _ kind target <<<"$1"
  if [[ "$kind" == rex && "$target" != "${REX_SESSION:-}" ]]; then
    rex kill "$target" >/dev/null
  fi
}

connect() {
  local kind target id label
  IFS=$'\t' read -r _ kind target <<<"$1"

  if [[ "$kind" == rex ]]; then
    id="$target"
  else
    label="$(session_label "$target")"
    id="$(rex ls --json | jq -r --arg l "$label" '.sessions[] | select(.label == $l) | .session_id' | head -n 1)"
    if [[ -z "$id" ]]; then
      id="$(rex new "$label" -c "$target" --json | jq -r '.session_id')"
    fi
  fi

  if ! rex do session.select session_id="$id"; then
    echo
    echo "Couldn't switch sessions. Turn on Remote Control in Rex.app Settings > Rex Server."
    read -r -n 1 -s -p "Press any key to close"
    return
  fi

  # For C-Space s in init.lua
  if [[ -n "${REX_SESSION:-}" && "$id" != "$REX_SESSION" ]]; then
    mkdir -p "$STATE_DIR"
    printf '%s\n' "$REX_SESSION" >"$LAST_FILE"
  fi
}

pick() {
  local choice
  choice="$(list all | fzf --no-border \
    --ansi \
    --list-border \
    --layout=reverse \
    --no-sort --prompt '⚡  ' \
    --color '16,hl:3:bold,hl+:11:bold' \
    --input-border \
    --header-border \
    --delimiter '\t' --with-nth 1 \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-b:abort' \
    --bind "ctrl-a:change-prompt(⚡  )+reload('$SELF' list all)" \
    --bind "ctrl-t:change-prompt(  )+reload('$SELF' list rex)" \
    --bind "ctrl-g:change-prompt(⚙️  )+reload('$SELF' list config)" \
    --bind "ctrl-x:change-prompt(📁  )+reload('$SELF' list zoxide)" \
    --bind "ctrl-f:change-prompt(🔎  )+reload('$SELF' list fd)" \
    --bind "ctrl-d:execute('$SELF' kill {})+change-prompt(⚡  )+reload('$SELF' list all)" \
    --preview-window 'right:50%' \
    --preview "'$SELF' preview {}")" || exit 0

  [[ -n "$choice" ]] && connect "$choice"
}

case "${1:-pick}" in
pick) pick ;;
list) list "${2:-all}" ;;
preview) preview "$2" ;;
kill) kill_session "$2" ;;
*)
  echo "usage: $(basename "$0") [list [SOURCE]|preview LINE|kill LINE]" >&2
  exit 2
  ;;
esac
