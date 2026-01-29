# Path configurations
typeset -U path
path=(
  /opt/homebrew/bin(N)
  ${ASDF_DATA_DIR:-$HOME/.asdf}/shims(N)
  ${HOME}/.local/bin(N)
  ${HOME}/.cargo/bin(N)
  /usr/local/opt/avr-gcc@8/bin(N)
  $path[@]
)

source ~/.config/zsh/aliases.zsh

# asdf setup (Homebrew installation)
. /opt/homebrew/opt/asdf/libexec/asdf.sh
fpath=(/opt/homebrew/opt/asdf/share/zsh/site-functions $fpath)

# Completion system
autoload -Uz compinit
# Only regenerate once a day for faster startup
if [[ -n ~/.zcompdump(#qNmh+24) ]]; then
  compinit -u
else
  compinit -C -u
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
zstyle ':completion:*' list-colors ''

# Disable autocomplete for man command for performance
zstyle ':completion:*:man:*' completer

#Order of groups can be configured with the zstyle group-order.

zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

export MANPAGER='nvim +Man!'
export MANWIDTH=999

# Default editor
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINFO_DIRS=$TERMINFO_DIRS:$HOME/.local/share/terminfo
export FZF_TMUX_OPTS="-p 55%,60%"
export ATAC_KEY_BINDINGS="/Users/mahadiahmed/.config/atac/vim_key_bindings.toml"

# zsh history settings
HISTSIZE=10000    # Number of commands in memory
SAVEHIST=50000    # Number of commands saved to HISTFILE
HISTFILE=~/.zsh_history  # Where history is saved
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
setopt HIST_FCNTL_LOCK           # Faster file locking
setopt HIST_FIND_NO_DUPS         # Don't display duplicates in search
unsetopt HIST_SAVE_BY_COPY       # Don't create temporary files

# Ignore specific commands in history
HISTORY_IGNORE="(ls|cd|pwd|exit|clear|export*)"

# Function to ignore specific commands in history
zshaddhistory() {
    local line=${1%%$'\n'}
    local cmd=${line%% *}
    [[ ${cmd} != (ls|cd|pwd|exit|clear|export) ]]
}

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git' # Optimize FZF
# export FZF_DEFAULT_OPTS='--height 40% --border'
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --style=numbers --color=always --line-range :500 {}'"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Autosuggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

source /opt/homebrew/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

zle     -N             sesh-sessions
bindkey -M emacs '^f' sesh-sessions
bindkey -M vicmd '^f' sesh-sessions
bindkey -M viins '^f' sesh-sessions

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Copy current command buffer to clipboard (macOS)
function copy-buffer-to-clipboard() {
  echo -n "$BUFFER" | pbcopy
  zle -M "Copied to clipboard"
}

zle -N copy-buffer-to-clipboard
bindkey '^Xc' copy-buffer-to-clipboard

# Clear screen but keep current command buffer
function clear-screen-and-scrollback() {
  echoti civis >"$TTY"
  printf '%b' '\e[H\e[2J\e[3J' >"$TTY"
  echoti cnorm >"$TTY"
  zle redisplay
}
zle -N clear-screen-and-scrollback
bindkey '^Xn' clear-screen-and-scrollback

eval "$(zoxide init zsh)"

function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

. "$HOME/.atuin/bin/env"

eval "$(mise activate zsh)"
eval "$(atuin init zsh)"
eval "$(starship init zsh)"

source <(menti activate)
