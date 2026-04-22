# Navigation
alias -- -='cd -'
alias ..='cd ..'
alias ...='cd ../..'

# Core commands
alias rd='rmdir'
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv}'
alias egrep='grep -E'
alias fgrep='grep -F'
## use eza instead of ls
alias ls='eza --icons --group-directories-first -w 80 --color=auto'
alias ll='eza --icons --group-directories-first -l --color=auto'
alias lsa='eza --icons --group-directories-first -a -w 80 --color=auto'
alias lt='eza --icons --group-directories-first --tree --git-ignore --color=auto'
alias l.='eza --icons --group-directories-first -d .* --color=auto'
alias lta='eza --icons --group-directories-first --tree --level=4 --git-ignore --color=auto'

alias lsg='fd -u --max-depth 1'

# Applications
alias cat='bat'
alias vim='nvim'
alias vimdiff='nvim -c "packadd nvim.difftool" -d'
alias f='open -a Finder ./'
alias lg='lazygit'
alias lvim='NVIM_APPNAME=lvim nvim'
alias icat="kitten icat"
# Route `claude` to the correct profile based on the current directory.
# Work: anything under ~/Code/menti → ~/.claude-work
# Personal: everything else → default ~/.claude
# Implemented as a function (not an alias) so we can branch on $PWD at launch.
claude() {
  local claude_bin="$HOME/.local/bin/claude"
  if _claude_is_work_dir; then
    print -P "%F{yellow}🏢 work profile%f"
    CLAUDE_CONFIG_DIR="$HOME/.claude-work" "$claude_bin" "$@"
  else
    "$claude_bin" "$@"
  fi
}

# ${PWD:A} resolves symlinks so a shortcut like `~/menti -> ~/Code/menti` still routes to work.
_claude_is_work_dir() {
  [[ "${PWD:A}" == "$HOME/Code/menti"/* ]]
}

# Escape-hatch aliases for explicit overrides (e.g. personal session from a work tmux pane).
# `claude-personal` must UNSET CLAUDE_CONFIG_DIR (not set it to ~/.claude): Claude branches
# on whether the var is set, and in "set" mode it reads $CLAUDE_CONFIG_DIR/.claude.json,
# but personal state lives at the legacy $HOME/.claude.json (one level up).
alias claude-personal='env -u CLAUDE_CONFIG_DIR         $HOME/.local/bin/claude'
alias claude-work='CLAUDE_CONFIG_DIR=$HOME/.claude-work $HOME/.local/bin/claude'

alias c='claude'

# AWS LocalStack
laws() { aws --endpoint-url=http://localhost:4566 "$@"; }

# Directory shortcuts
alias cdpn='cd ~/Code/pn-repos/'
alias cdqmk='cd ~/Code/mahadia/qmk/keyboards/planck/keymaps/mahadia'

# Utility
alias cpdir='cp -rf'
alias cpwd='pwd | pbcopy && echo "path copied to clipboard"'
alias rc='vim ~/.zshrc'
alias rsource='source ~/.zshrc'
alias moveSc='/Users/mahadiahmed/Code/mahadia/Util-Scripts/screenshot_mover/screenshot_mover'


# FZF integration
alias v='fd --hidden --exclude .git | fzf-tmux -p --height 40% --layout=reverse --border --preview "bat --style=numbers --color=always --line-range :500 {}" | xargs nvim'
alias vp='fd --hidden --exclude .git | fzf --height 40% --layout=reverse --border --preview "bat --style=numbers --color=always --line-range :500 {}" | xargs nvim'

# Git aliases
alias glg='git log -n 40 --graph --decorate'
alias gp='git pull'
alias gst='git status'

# Worktrunk (tmux post-switch hook handles session creation)
alias wts='wt switch --no-cd'
alias wtc='wt switch --no-cd --create'
