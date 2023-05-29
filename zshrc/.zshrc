# If you come from bash you might have to change your $PATH.
#export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/.local/bin:/usr/local/opt/avr-gcc@8/bin:$PATH

# source "/usr/local/opt/spaceship/spaceship.zsh"

# Path to your oh-my-zsh installation.
export ZSH="/Users/mahadiahmed/.oh-my-zsh"
export MANPAGER='nvim +Man!'
export MANWIDTH=999
export TERMINFO_DIRS=$TERMINFO_DIRS:$HOME/.local/share/terminfo

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"
# echo -n -e "\033]0;CLIENT\007"
# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use anuother custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-vi-mode)

source $ZSH/oh-my-zsh.sh

# SPACESHIP
# SPACESHIP_PROMPT_ORDER=(
#   user
#   host
#   dir
#   node
#   package
#   python
#   rust
#   java
#   lua
#   docker
#   aws
#   kubectl
#   golang
#   async
#   git
#   line_sep
#   char
# )

# # SPACESHIP_PROMPT_ASYNC=true
# SPACESHIP_NODE_ASYNC=false
# SPACESHIP_ASYNC_SHOW_COUNT=true
# SPACESHIP_GIT_BRANCH_ASYNC=true
# SPACESHIP_GIT_ASYNC=false

# SPACESHIP_PROMPT_FIRST_PREFIX_SHOW=false	
# SPACESHIP_TIME_SHOW=true

# SPACESHIP_PROMPT_ORDER=(
#   user
#   host
#   dir
#   git
#   node
#   docker
#   aws
#   python
#   java
#   conda
#   async
#   line_sep
#   char
# )

# title bar prompt
# precmd () {
#   print -Pn "\e]2;%n@%M | %~\a" 
# } 
#

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

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='lvim'
 fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Look into the file in ~/.oh-my-zsh/custom/aliases.zsh for list of custom aliases

function codeauth () {
    node /Users/mahadiahmed/Code/snippets/tokenCodeClipboard/index.js $1
}

echo "IBN5100: Lab Member 003 Suuppar Hacker: El Psy Congroo "

# Set typewritten ZSH as a prompt

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/mahadiahmed/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/mahadiahmed/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/mahadiahmed/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/mahadiahmed/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /Users/mahadiahmed/Code/pn-repos/ncp/postnord-ncp-change-shipment/node_modules/tabtab/.completions/serverless.zsh ]] && . /Users/mahadiahmed/Code/pn-repos/ncp/postnord-ncp-change-shipment/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /Users/mahadiahmed/Code/pn-repos/ncp/postnord-ncp-change-shipment/node_modules/tabtab/.completions/sls.zsh ]] && . /Users/mahadiahmed/Code/pn-repos/ncp/postnord-ncp-change-shipment/node_modules/tabtab/.completions/sls.zsh

# export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
# export FZF_DEFAULT_OPTS='--height 40% --border'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --style=numbers --color=always --line-range :500 {}'"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

source ~/powerlevel10k/powerlevel10k.zsh-theme

eval "$(zoxide init zsh)"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
