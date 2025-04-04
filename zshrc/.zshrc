# TODO: Add tab to complete suggestion
# Enable Powerlevel10k instant prompt (must be at the very top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Only enable zprof if debugging performance
# zmodload zsh/zprof  # Top of file
# zmodload zsh/datetime  # For timestamps

# Optimize compinit - only check for new functions once per day
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Completion styling and cache settings
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
mkdir -p ~/.zsh/cache

# Path configurations
typeset -U path
path=(
  /opt/homebrew/bin(N)
  ${HOME}/.volta/bin(N)
  ${HOME}/.local/bin(N)
  /usr/local/opt/avr-gcc@8/bin(N)
  $path[@]
)

source "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git/zinit.zsh"

zinit ice depth=1
zinit light romkatv/powerlevel10k

# Load core plugins
zinit wait lucid light-mode for \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions

source ~/.config/zsh/aliases.zsh

export MANPAGER='nvim +Man!'
export MANWIDTH=999
export TERMINFO_DIRS=$TERMINFO_DIRS:$HOME/.local/share/terminfo
export FZF_TMUX_OPTS="-p 55%,60%"
export ATAC_KEY_BINDINGS="/Users/mahadiahmed/.config/atac/vim_key_bindings.toml"

# zsh history settings
HISTSIZE=50000    # Number of commands in memory
SAVEHIST=50000    # Number of commands saved to HISTFILE
HISTFILE=~/.zsh_history  # Where history is saved
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
setopt HIST_FCNTL_LOCK           # Faster file locking
setopt HIST_FIND_NO_DUPS         # Don't display duplicates in search
setopt EXTENDED_HISTORY          # Save timestamp and duration
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

zinit ice as"completion"
zinit snippet /usr/local/bin/terraform

zle     -N             sesh-sessions
bindkey -M emacs '^f' sesh-sessions
bindkey -M vicmd '^f' sesh-sessions
bindkey -M viins '^f' sesh-sessions

eval "$(zoxide init zsh --cmd j)" # NOTE: Rename z prefix to j

function codeauth () {
    node /Users/mahadiahmed/Code/snippets/tokenCodeClipboard/index.js $1
}

function zed() {
    open "$1" -a Zed
}

# TODO: Figure out how to only show this when Last login msg is printed
# echo "IBN5100: Lab Member 003 Suuppar Hacker: El Psy Congroo "

# Set typewritten ZSH as a prompt

# Lazy load conda
conda-init() {
  eval "$('/Users/mahadiahmed/opt/anaconda3/bin/conda' 'shell.zsh' 'hook')"
}


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).

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

function gcloud() {
    unfunction gcloud
    if [ -f '/Users/mahadiahmed/google-cloud-sdk/path.zsh.inc' ]; then 
        . '/Users/mahadiahmed/google-cloud-sdk/path.zsh.inc'
        . '/Users/mahadiahmed/google-cloud-sdk/completion.zsh.inc'
    fi
    gcloud "$@"
}

eval "$(direnv hook zsh)"

# At the bottom of .zshrc
# Log zsh profiling data with timestamp
# zsh-profile-log() {
#   local log_dir="$HOME/.zsh_profile_logs"
#   mkdir -p "$log_dir"  # Create directory if it doesn't exist
#   
#   # Create filename with timestamp
#   local timestamp=$(strftime '%Y%m%d_%H%M%S' $EPOCHSECONDS)
#   local log_file="$log_dir/zsh_profile_$timestamp.log"
#   
#   # Write profile data to file
#   echo "=== Profile data for $(strftime '%Y-%m-%d %H:%M:%S' $EPOCHSECONDS) ===" > "$log_file"
#   zprof >> "$log_file"
# }

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/mahadiahmed/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# bun completions
[ -s "/Users/mahadiahmed/.bun/_bun" ] && source "/Users/mahadiahmed/.bun/_bun"

# zsh-profile-log  # Bottom of file (uncomment to debug)
