complete -cf sudo
. "$HOME/.cargo/env"

GPG_TTY=$(tty)
export GPG_TTY
