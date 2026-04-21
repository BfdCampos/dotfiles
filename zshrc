# Detect the operating system
case "$(uname -s)" in
  Darwin)
    # Add Homebrew to the PATH
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

    # Add /usr/local/bin to the PATH
    export PATH=/usr/local/bin:$PATH

    # Go PATH 
    export GOPATH=$HOME/go

    # NVM settings
    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"

    # poetry
    export PATH="$HOME/.local/bin:$PATH"
    
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
alias cl='clear'
alias sauce='source ~/.zshrc'

# Git aliases
alias gcom='git checkout $(git for-each-ref --format="%(refname:short)" refs/remotes/origin/main refs/remotes/origin/master 2>/dev/null | head -1 | sed "s/origin\///")'
alias gdtool='git difftool '
alias gdiff='git difftool '

# Git branch helpers
git_current_branch() {
  git branch --show-current 2> /dev/null || 
  git rev-parse --abbrev-ref HEAD 2> /dev/null
}

git_default_branch() {
  git symbolic-ref refs/remotes/origin/HEAD 2> /dev/null | 
  sed "s@^refs/remotes/origin/@@" ||
  echo "main"
}

# Personal Git config
alias gitconfigpersonal='git config user.name "Bruno Campos" && git config user.email "brunofdcampos@hotmail.com" && git config user.signingkey A36BFB88B3217C2B'

# Load active shell modules
if [ -d ~/.zsh_active ]; then
  for module in ~/.zsh_active/*.zsh(N); do
    source "$module"
  done
fi

# Tree alias if installed
if command -v tree &>/dev/null; then
  alias tr="tree -a -I '.git|node_modules|bower_components|vendor|dist|build|coverage|__pycache__|.venv|.idea|.vscode' --dirsfirst --noreport --prune"
fi

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh settings
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search history)

source $ZSH/oh-my-zsh.sh

# alias specific oh my zsh alias overwrite
(( $+aliases[ll] )) && unalias ll
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

# Load the command-line completion system
if [[ ! -d "$HOME/.zcompdump" ]]; then
  autoload -Uz compinit && compinit -d "$HOME/.zcompdump"
else
  autoload -Uz compinit && compinit -C
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Python/Pipx
export PATH="$PATH:$HOME/.local/bin"

# Zoxide
eval "$(zoxide init zsh --cmd cd)"

# Pyenv
export PYENV_ROOT=$(brew --prefix)/var/pyenv
export PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi

# Google Cloud SDK
if [ -d "/opt/homebrew/share/google-cloud-sdk" ]; then
  source /opt/homebrew/share/google-cloud-sdk/path.zsh.inc
  source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc
fi
export CLOUDSDK_PYTHON=/opt/homebrew/bin/python3.13

# Rbenv
if command -v rbenv &>/dev/null; then
  eval "$(rbenv init -)"
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# ai ask
ai() {
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local pid
  claude -p "$*" &
  pid=$!
  while kill -0 $pid 2>/dev/null; do
    for ((i=0; i<${#spin}; i++)); do
      printf "\r${spin:$i:1} Thinking..."
      sleep 0.1
    done
  done
  printf "\r\033[K"
  wait $pid
}
