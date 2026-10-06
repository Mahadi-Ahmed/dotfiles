#!/bin/sh
# Lists tmux panes that have a Claude Code agent status, most urgent first.
# Status is written by ~/.claude/hooks/agent-status.sh into the pane options
# @agent_status (waiting|done|working|idle) and @agent_status_at (epoch seconds).
# Output: a header row, then per pane the display columns, a tab and the
# pane id (for fzf to jump to). Use with fzf --header-lines 1.
tab=$(printf '\t')
now=$(date +%s)
repo_name="$HOME/.config/tmux/scripts/git-repo-name.sh"

red=$(printf '\033[31m')
green=$(printf '\033[32m')
yellow=$(printf '\033[33m')
dim=$(printf '\033[2m')
reset=$(printf '\033[0m')

# Size repo and session columns to the terminal we're drawn in (the popup).
# Fixed columns: status 8, pane 5, age 4, 4 separators, ~4 for fzf's gutter.
cols=$({ stty size </dev/tty; } 2>/dev/null | cut -d' ' -f2)
cols=${cols:-120}
flex=$(((cols - 8 - 5 - 4 - 4 - 4) / 2))
[ "$flex" -lt 12 ] && flex=12

# printf pads by bytes: the repo icon is 3 bytes but 1 column wide, so the
# repo cells look 2 columns narrower than $flex. The header matches that.
printf "%-8s %-${flex}s %-$((flex - 2))s %-5s %4s\n" STATUS SESSION 'REPO / DIR' PANE AGE

tmux list-panes -a -F "#{@agent_status}${tab}#{@agent_status_at}${tab}#{session_name}${tab}#{window_index}.#{pane_index}${tab}#{pane_id}${tab}#{pane_current_path}" 2>/dev/null |
  awk -F'\t' -v OFS='\t' '
    $1 == "" { next }               # not an agent pane
    $2 == "" { $2 = "-" }           # keep the field so read does not shift columns
    {
      rank = ($1 == "waiting") ? 1 : ($1 == "done") ? 2 : ($1 == "idle") ? 4 : 3
      print rank, $0
    }' |
  sort -t "$tab" -k1,1n -k3,3n |    # by status, then oldest change first
  while IFS="$tab" read -r _rank status at session winpane pane path; do
    case "$status" in
      waiting) color=$red ;;
      done)    color=$green ;;
      idle)    color=$dim ;;
      *)       color=$yellow ;;
    esac

    if [ "$at" = "-" ]; then
      age="?"
    else
      secs=$((now - at))
      if [ "$secs" -lt 60 ]; then age="${secs}s"
      elif [ "$secs" -lt 3600 ]; then age="$((secs / 60))m"
      else age="$((secs / 3600))h"
      fi
    fi

    # "<icon> <name or path>". Long paths keep their tail, the end is the
    # interesting part: the icon and space take 2 columns, "..." takes 3.
    repo=$("$repo_name" "$path")
    icon=${repo%% *}
    name=${repo#* }
    if [ "${#name}" -gt $((flex - 4)) ]; then
      repo="$icon ...$(printf '%s' "$name" | tail -c $((flex - 7)))"
    fi
    printf "%s%-8s%s %-${flex}s %-${flex}.${flex}s %-5s %4s\t%s\n" \
      "$color" "$status" "$reset" "$session" "$repo" "$winpane" "$age" "$pane"
  done
