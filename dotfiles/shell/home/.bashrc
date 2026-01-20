#
# ~/.bashrc
#

export EDITOR=nano
export VISUAL="codium --wait"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Bold "thigglez" in #AC82E9, then >
PS1='\[\e[1m\e[38;2;172;130;233m\]thigglez\[\e[0m\] > '

# Neofetch on interactive shells (force Leo ASCII in bash)
case $- in
  *i*) command -v neofetch >/dev/null && neofetch --backend ascii --source "$HOME/.config/neofetch/leo_ascii" ;;
esac

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# systemd ssh-agent
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
