source /usr/share/cachyos-zsh-config/cachyos-config.zsh

# Disable Powerlevel10k prompt hooks so Starship controls the prompt.
precmd_functions=(${precmd_functions:#_p9k_precmd*})
preexec_functions=(${preexec_functions:#_p9k_preexec*})

# Starship prompt
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
eval "$(starship init zsh)"

# Run neofetch on Kitty startup.
if [[ -n "$KITTY_PID" && -o interactive ]]; then
  neofetch
fi
