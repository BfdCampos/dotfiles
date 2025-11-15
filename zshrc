# Detect the operating system
case "$(uname -s)" in
  Darwin)
    # MacOS specific commands here

    # Add /usr/local/bin to the PATH
    export PATH=/usr/local/bin:$PATH

    # Go PATH 
    export GOPATH=$HOME/go

    # Update the prompt to include the virtualenv_info function
    #export PROMPT='$(virtualenv_info)%n: (%1~) $vcs_info_msg_0_ -> '

    # Add OpenJDK to the PATH and CPPFLAGS
    export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
    export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

    # Virtualenvwrapper settings:
    source virtualenvwrapper.sh

    export VIRTUALENVWRAPPER_PYTHON=/opt/homebrew/bin/python3.9
    export WORKON_HOME=$HOME/.virtualenvs
    # export VIRTUALENVWRAPPER_VIRTUALENV=/opt/homebrew/bin/virtualenvwrapper # Old way of doing it it seems
    export VIRTUALENVWRAPPER_WORKON_CD=1
    export PROJECT_HOME=$HOME/projects

    # NVM settings
    # This loads nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
    export PATH="/usr/local/opt/mongodb-community@5.0/bin:$PATH"
    export PATH="/opt/homebrew/opt/mongodb-community@5.0/bin:$PATH"

    # pnpm
    export PNPM_HOME="/Users/bruno.campos/Library/pnpm"
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
    # pnpm end

    # poetry
    export PATH="$HOME/.local/bin:$PATH"

    #######################################################################################
    ########################## Company Specific Settings ##################################
    #######################################################################################
    
esac

# bat pager settings set to never
export BAT_PAGER=""

# complete -cf sudo
setopt glob_dots

# Set GPG_TTY to the terminal device name
GPG_TTY=$(tty)
export GPG_TTY

# Custom aliases
alias please=sudo

alias ls=' ls -lhF --time-style=long-iso --color=auto'
alias ..="cd .."
alias cp='cp -iv'

alias v="nvim"
alias ffluff='sqlfluff fix -f --show-lint-violations '
alias fflufff='sqlfluff fix -f --show-lint-violations -v --FIX-EVEN-UNPARSABLE '

# Get the current branch name
git_current_branch() {
  git branch --show-current 2> /dev/null || 
  git rev-parse --abbrev-ref HEAD 2> /dev/null
}

# Get the default branch name
git_default_branch() {
  git symbolic-ref refs/remotes/origin/HEAD 2> /dev/null | 
  sed "s@^refs/remotes/origin/@@" ||
  echo "main" # Fallback to "main" if the command fails
}
main() {
  git symbolic-ref refs/remotes/origin/HEAD 2> /dev/null | 
  sed "s@^refs/remotes/origin/@@" ||
  echo "main" # Fallback to "main" if the command fails
}

alias gcom='git checkout $(git for-each-ref --format="%(refname:short)" refs/remotes/origin/main refs/remotes/origin/master 2>/dev/null | head -1 | sed "s/origin\///")'
alias gdtool='git difftool '
alias gdiff='git difftool '
alias gcdiff='git difftool $(git_default_branch)..$(git_current_branch)'
alias gfug='git ls-files --others --exclude-standard | grep'

alias sql='duckdb -c '

alias sauce='source ~/.zshrc'

alias cl='clear'

# Add git configs
# Personal gpg M4 Monzo Mac
alias gitconfigpersonal='git config user.name "Bruno Campos" && git config user.email "brunofdcampos@hotmail.com" && git config user.signingkey A36BFB88B3217C2B'
# Monzo gpg M4 Monzo Mac
alias gitconfigmonzo='git config user.name "Bruno Campos" && git config user.email "brunocampos@monzo.com" && git config user.signingkey 7C867AAC0E30CEDD'

# if tree is installed then alias
if command -v tree &>/dev/null; then
  alias tr="tree -a -I '.git|node_modules|bower_components|vendor|dist|build|coverage|__pycache__|.venv|.idea|.vscode' --dirsfirst --noreport --prune"
else
  echo "tree command not found, skipping alias creation."
fi

# if linux, alias open to xdg-open, if mac, alias open to open else open to explorer.exe
case "$(uname -s)" in
  Linux)
    alias open=xdg-open
    ;;
  Darwin)
    alias open=open
    ;;
  *)
    alias open=explorer.exe
    ;;
esac

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

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

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

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

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search history)

source $ZSH/oh-my-zsh.sh

# alias specific oh my zsh alias overwrite
unalias ll
function ll() {
  command ls -lah
  if [[ -f README.md ]]; then
    if command -v bat &>/dev/null; then
      echo "\n--- README.md ---\n"
      bat README.md
    else
      echo "\n--- README.md ---\n"
      cat README.md
    fi
  fi
}

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# 
# My old zshrc

# Load the command-line completion system
autoload -Uz compinit && compinit

# Load the version control system hooks and configuration
#autoload -Uz add-zsh-hook
#autoload -Uz vcs_info
#
#add-zsh-hook precmd vcs_info
#
#zstyle ':vcs_info:*' enable git
#zstyle ':vcs_info:*' formats " %F{green}%c%u(%b)%f"
#zstyle ':vcs_info:*' actionformats " %F{green}%c%u(%b)%f %a"
#zstyle ':vcs_info:*' stagedstr "%F{yellow}"
#zstyle ':vcs_info:*' unstagedstr "%F{red}"
#zstyle ':vcs_info:*' check-for-changes true
#
#zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
#
# Define a hook function to show untracked files in the version control info
#+vi-git-untracked() {
#  if git --no-optional-locks status --porcelain 2> /dev/null | grep -q "^??"; then
#    hook_com[staged]+="%F{red}"
#  fi
#}
#
# Configure the prompt to show the current working directory and version control status
#setopt PROMPT_SUBST
#
# Define a function to check if in a virtual environment
function virtualenv_info() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo -n "%F{blue}(venv)%f "
  else
    echo -n "%F{red}(no-venv)%f "
  fi
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# bun completions
[ -s "/Users/bruno.campos/.bun/_bun" ] && source "/Users/bruno.campos/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# eval "$(gh copilot alias -- zsh)"

# Created by `pipx` on 2024-06-18 16:04:46
export PATH="$PATH:/Users/brunocampos/.local/bin"

export PATH=$HOME/.rill:$PATH # Added by Rill install

eval "$(zoxide init zsh --cmd cd)"

# Fix circular dependency for zoxide on Linux
if [[ "$(uname -s)" != "Darwin" ]]; then
  # Override _z_cd to use builtin cd directly, avoiding the alias
  _z_cd() {
    builtin cd "$@" || return "$?"
    if [ "$_ZO_ECHO" = "1" ]; then
      echo "$PWD"
    fi
  }
  
  # On Ubuntu/Debian, bat is installed as batcat
  if command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
  fi
fi
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PYENV_ROOT=$(brew --prefix)/var/pyenv
export PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi
export PATH=/Users/brunocampos/.local/bin:$PATH
source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
export CLOUDSDK_PYTHON=/Users/brunocampos/.pyenv/versions/3.9.10/bin/python
export OAUTHLIB_RELAX_TOKEN_SCOPE=1
source /Users/brunocampos/src/github.com/monzo/analytics/dbt/misc/shell/source.sh

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/brunocampos/.lmstudio/bin"
export PATH=/Users/brunocampos/.local/bin:$PATH
export PATH=/Users/brunocampos/.local/bin:$PATH
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
eval "$(rbenv init -)"

# For adbt target output
copy_target() {
  local dest_name="${1:-dbt_target}"
  local dest_path="$HOME/src/github.com/monzo/analytics/dbt/$dest_name"

  container_id=$(docker ps -q --filter "ancestor=us-central1-docker.pkg.dev/monzo-build/dbt-monzo-shell/dbt-monzo-shell:master")

  if [[ -z "$container_id" ]]; then
    echo "No running dbt container found."
    return 1
  fi

  tmp_target=$(docker exec "$container_id" sh -c 'find /tmp/ -type d -path "*/target" -print0 | xargs -0 stat --format "%Y %n" | sort -nr | head -1 | cut -d" " -f2-')

  if [[ -z "$tmp_target" ]]; then
    echo "Could not find a target folder in /tmp/"
    return 1
  fi

  tmp_root=$(dirname "$tmp_target")

  docker cp "${container_id}:${tmp_root}" ./_tmp_target_copy

  if [[ ! -d "./_tmp_target_copy" ]]; then
    echo "Copy failed — _tmp_target_copy does not exist."
    return 1
  fi

  real_target_path=$(find ./_tmp_target_copy -type d -name target | head -n 1)

  if [[ -z "$real_target_path" ]]; then
    echo "Could not find the target folder inside _tmp_target_copy."
    rm -rf ./_tmp_target_copy
    return 1
  fi

  mkdir -p "$(dirname "$dest_path")"
  mv "$real_target_path" "$dest_path"

  rm -rf ./_tmp_target_copy

}

# Monzo specific terminal commands

# To capture an image of your terminal command output in dbt-monzo shell
terminal_capture() {

    # Check if termshot is installed
    if ! command -v termshot &> /dev/null; then
        echo "❌ termshot is not installed"
        echo "Install it with: brew install homeport/tap/termshot"
        return 1
    fi

    # Check if command was provided
    if [ -z "$1" ]; then
        echo "Usage: terminal_capture <command>"
        echo "Example: terminal_capture adbt run -s my_model"
        return 1
    fi
    
    # Find the dbt-monzo-shell container ID
    CONTAINER_ID=$(docker ps --format "{{.ID}}" --filter "ancestor=us-central1-docker.pkg.dev/monzo-build/dbt-monzo-shell/dbt-monzo-shell:master" | head -1)
    
    # Check if container was found
    if [ -z "$CONTAINER_ID" ]; then
        echo "Error: No dbt-monzo-shell container found running"
        echo "Run 'dbt-monzo' first to start the container"
        return 1
    fi
    
    # Generate filename with timestamp
    FILENAME="termshot_output_$(date +%Y%m%d_%H%M%S).png"
    
    echo "📸 Found container: $CONTAINER_ID"
    echo "🏃 Running: $@"
    echo "---"
    
    # Run termshot and save to file
    termshot --filename "$FILENAME" -- "docker exec -t $CONTAINER_ID $@ 2>&1"
    
    # Copy the PNG to clipboard
    osascript -e "set the clipboard to (read (POSIX file \"$PWD/$FILENAME\") as «class PNGf»)"
    
    echo "✅ Screenshot saved to: $FILENAME"
    echo "📋 Copied to clipboard!"
}

# Alias for even quicker access
alias tcap='terminal_capture'

# run dbt-monzo shell commands from any terminal
monzo() {
  CONTAINER_ID=$(docker ps --format "{{.ID}}" --filter "ancestor=us-central1-docker.pkg.dev/monzo-build/dbt-monzo-shell/dbt-monzo-shell:master" | head -1)
  if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No dbt-monzo-shell container found running"
    echo "Run 'docker run' command to start the container"
    return 1
  fi

  # Check if running in an interactive terminal
  if [ -t 1 ] && [ -t 0 ]; then
    # Interactive mode (humans)
    docker exec -it "$CONTAINER_ID" "$@"
  else
    # Non-interactive mode (Claude Code, scripts, etc.)
    docker exec "$CONTAINER_ID" "$@"
  fi
}

# run modelgen commands from any terminal
modelgen() {
  CONTAINER_ID=$(docker ps --format "{{.ID}}" --filter "ancestor=us-central1-docker.pkg.dev/monzo-build/dbt-monzo-shell/dbt-monzo-shell:master" | head -1)
  if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No dbt-monzo-shell container found running"
    echo "Run 'dbt-monzo' first to start the container"
    return 1
  fi

  # Check if running in an interactive terminal
  if [ -t 1 ] && [ -t 0 ]; then
    docker exec -it "$CONTAINER_ID" modelgen "$@"
  else
    docker exec "$CONTAINER_ID" modelgen "$@"
  fi
}

# run adbt commands from any terminal
adbt() {
  CONTAINER_ID=$(docker ps --format "{{.ID}}" --filter "ancestor=us-central1-docker.pkg.dev/monzo-build/dbt-monzo-shell/dbt-monzo-shell:master" | head -1)
  if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No dbt-monzo-shell container found running"
    echo "Run 'dbt-monzo' first to start the container"
    return 1
  fi

  # Check if running in an interactive terminal
  if [ -t 1 ] && [ -t 0 ]; then
    docker exec -it "$CONTAINER_ID" adbt "$@"
  else
    docker exec "$CONTAINER_ID" adbt "$@"
  fi
}

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# dbt aliases
alias dbtf=/Users/brunocampos/.local/bin/dbt
[ -f ${GOPATH}/src/github.com/monzo/starter-pack/zshrc ] && source ${GOPATH}/src/github.com/monzo/starter-pack/zshrc
