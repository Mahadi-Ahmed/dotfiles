#!/bin/sh
# fzf picker over agents.sh, meant to run inside tmux display-popup.
# Starts in navigation mode: j/k move, enter jumps to the pane, q/esc quit.
# / shows the filter input; esc hides it again and goes back to navigating.
pane=$("$HOME/.config/tmux/scripts/agents.sh" |
  fzf --ansi --header-lines 1 --delimiter '\t' --with-nth 1 --no-sort \
    --no-border --list-border --input-border --header-border --color '16,hl:3:bold,hl+:11:bold' \
    --prompt '🤖  ' \
    --no-input \
    --bind 'j:down,k:up,q:abort' \
    --bind '/:show-input+unbind(j,k,q,/)' \
    --bind 'esc:transform:[ "$FZF_INPUT_STATE" = enabled ] && echo "clear-query+hide-input+rebind(j,k,q,/)" || echo abort' |
  cut -f2)

[ -n "$pane" ] && tmux switch-client -t "$pane"
