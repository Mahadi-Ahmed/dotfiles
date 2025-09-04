if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path configurations
typeset -U path
path=(
  /opt/homebrew/bin(N)
  ${HOME}/.volta/bin(N)
  ${HOME}/.local/bin(N)
  /usr/local/opt/avr-gcc@8/bin(N)
  $path[@]
)

source ~/powerlevel10k/powerlevel10k.zsh-theme
source ~/.config/zsh/aliases.zsh

# Completion system
autoload -Uz compinit
# Only regenerate once a day for faster startup
if [[ -n ~/.zcompdump(#qNmh+24) ]]; then
  compinit -u
else
  compinit -C -u
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''

# Disable autocomplete for man command for performance
zstyle ':completion:*:man:*' completer

export MANPAGER='nvim +Man!'
export MANWIDTH=999
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

function zsh_directory_name() {
  emulate -L zsh
  [[ $1 == d ]] || return
  while [[ $2 != / ]]; do
    if [[ -e $2/.git ]]; then
      typeset -ga reply=(${2:t} $#2)
      # echo ${2:t} $#2
      # echo ${2:t} 
      # echo ${2:h} 
      return
    fi
    2=${2:h}
  done
  return 1
}

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git' # Optimize FZF
# export FZF_DEFAULT_OPTS='--height 40% --border'
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --style=numbers --color=always --line-range :500 {}'"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Autosuggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

source /opt/homebrew/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

zle     -N             sesh-sessions
bindkey -M emacs '^f' sesh-sessions
bindkey -M vicmd '^f' sesh-sessions
bindkey -M viins '^f' sesh-sessions


eval "$(zoxide init zsh)"

# Ruby
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh

function codeauth () {
    node /Users/mahadiahmed/Code/snippets/tokenCodeClipboard/index.js $1
}

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
