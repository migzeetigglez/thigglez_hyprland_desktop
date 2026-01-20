source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# ~/.config/fish/config.fish

if status is-interactive
    # Editors
    set -gx EDITOR vim
    set -gx VISUAL codium --wait
end

function fish_greeting
    if type -q neofetch
        neofetch --backend kitty --source "$HOME/.config/fish/shark_head.png"
    end
end
