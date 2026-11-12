# dotfiles

managed with stow

# usage
```
# home configuration
stow nvim -t $HOME
stow tmux -t $HOME
stow emacs -t $HOME

# sfx for git
stow sounds -t $HOME/.local/share/sounds

# XDG configuration
stow git -t $HOME/.config/git
stow opencode -t $HOME/.config/opencode
stow atuin -t $HOME/.config/atuin

# macos configuration
stow nushell -t `~/Library/Application Support/nushell`
```
