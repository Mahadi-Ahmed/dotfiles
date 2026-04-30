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
alias bat='batcat'
alias cat='batcat'
alias vim='nvim'
alias vimdiff='nvim -d'

# Utility
alias cpdir='cp -rf'
alias rc='vim ~/.zshrc'
alias rsource='source ~/.zshrc'

# FZF integration
alias v='fd --hidden --exclude .git | fzf --height 40% --layout=reverse --border --preview "batcat --style=numbers --color=always --line-range :500 {}" | xargs nvim'

# Git aliases
alias glg='git log -n 40 --graph --decorate'
alias gp='git pull'
alias gst='git status'
