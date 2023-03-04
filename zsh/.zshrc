# Add /usr/local/bin to the PATH
export PATH=/usr/local/bin:$PATH

# Configure command-line completions for the `sudo` command
complete -cf sudo

# Set GPG_TTY to the terminal device name
GPG_TTY=$(tty)
export GPG_TTY

# Custom aliases
alias morning='./Start\ Up/Start\ Up\ Script.txt'
alias please=sudo
alias ibrew='arch -arm64 brew'

alias python="/opt/homebrew/bin/python3.9"
alias pip="/opt/homebrew/bin/pip3.9"

alias ...="cd .."

alias v="nvim"

# Load the command-line completion system
autoload -Uz compinit && compinit

# Load the version control system hooks and configuration
autoload -Uz add-zsh-hook
autoload -Uz vcs_info

add-zsh-hook precmd vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats " %F{green}%c%u(%b)%f"
zstyle ':vcs_info:*' actionformats " %F{green}%c%u(%b)%f %a"
zstyle ':vcs_info:*' stagedstr "%F{yellow}"
zstyle ':vcs_info:*' unstagedstr "%F{red}"
zstyle ':vcs_info:*' check-for-changes true

zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

# Define a hook function to show untracked files in the version control info
+vi-git-untracked() {
  if git --no-optional-locks status --porcelain 2> /dev/null | grep -q "^??"; then
    hook_com[staged]+="%F{red}"
  fi
}

# Configure the prompt to show the current working directory and version control status
setopt PROMPT_SUBST

# Define a function to check if in a virtual environment
function virtualenv_info() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo -n "%F{blue}(venv)%f "
  else
    echo -n "%F{red}(no-venv)%f "
  fi
}

# Update the prompt to include the virtualenv_info function
export PROMPT='$(virtualenv_info)%n: (%1~) $vcs_info_msg_0_ -> '

# Add OpenJDK to the PATH and CPPFLAGS
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

# PyEnv Set up
export PYENV_ROOT="$HOME/.pyenv" 
export PATH="$PYENV_ROOT/bin:$PATH" 
eval "$(pyenv init --path)" 
eval "$(pyenv init -)"

# Virtualenvwrapper settings:
export VIRTUALENVWRAPPER_PYTHON=/opt/homebrew/bin/python3.9
export WORKON_HOME=$HOME/.virtualenv
export VIRTUALENVWRAPPER_VIRTUALENV=/opt/homebrew/bin/virtualenv
export VIRTUALENVWRAPPER_WORKON_CD=1
export PROJECT_HOME=$HOME/projects

source /opt/homebrew/bin/virtualenvwrapper.sh

