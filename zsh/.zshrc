#!/bin/zsh

# user functions
# ==============
# generate silicon images + view them
function mksilicon() {
  INPUT="$1"
  OUTPUT="$2"
  shift 2
  silicon "$INPUT" --output "$OUTPUT" --no-line-number --no-window-controls "$@" && feh "$OUTPUT"
}

# locale
# ======
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# set window title
# ================
setWindowTitle() { print -Pn "\e]0;${1}\a" }

# exa
# ===
if which exa >/dev/null; then
  alias ls='exa'
fi

# term
# ====
export TERM=xterm-256color

# nix
# ===
if [[ -f ${HOME}/.nix-profile/etc/profile.d/nix.sh ]]; then
  source "${HOME}/.nix-profile/etc/profile.d/nix.sh"
fi

# editor
# ======
if [[ -z $SSH_CONNECTION ]]; then
  export EDITOR="emacsclient -nw"
else
  export EDITOR="emacsclient"
fi

# PATH
# ====
export PATH="/usr/local/bin:${HOME}/.local/bin:${PATH}"

# zplug
# =====
if [[ ! -d ~/.zplug ]]; then
    echo "installing zplug..."
    git clone https://github.com/b4b4r07/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

zplug 'zplug/zplug', hook-build:'zplug --self-manage'

zplug 'sharat87/zsh-vim-mode'
# zplug 'jeffreytse/zsh-vi-mode'
zplug 'zdharma/history-search-multi-word', defer:3
zplug 'chisui/zsh-nix-shell'
zplug 'spwhitt/nix-zsh-completions'
zplug 'romkatv/powerlevel10k', as:theme, depth:1
zplug 'Aloxaf/fzf-tab', defer:2
zplug 'zsh-users/zsh-autosuggestions', defer:3
zplug 'zdharma/fast-syntax-highlighting', defer:3

if ! zplug check; then
    zplug install
fi

zplug load

# cmdline editing
# ===============
autoload edit-command-line
bindkey -M vicmd v edit-command-line
zle -N edit-command-line

# history
# =======
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# git
# ===
export DISABLE_UNTRACKED_FILES_DIRTY="true"
export DISABLE_AUTO_UPDATE="true"

# ansible
# =======
export ANSIBLE_NOCOWS=1

# gpg
# ===
export GPG_TTY=$(tty)
export PINENTRY_USER_DATA="USE_CURSES=1"
gpg-ssh() { export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)" }

# gcloud
# ======

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/stricklanj/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/stricklanj/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/stricklanj/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/stricklanj/google-cloud-sdk/completion.zsh.inc'; fi

# powerline10k
# ============
if [[ -f ~/.p10k.zsh ]]; then
  if [[ -z $SSH_CONNECTION ]]; then
    source ~/.p10k.zsh
  else
    source ~/.p10k.ssh.zsh
  fi
fi

function torrent-search() {
  curl -sLG 'http://localhost:9117/torznab/all' \
    -d "apikey=$(pass show jackett/api-key 2>/dev/null)" \
    --data-urlencode q="$*" \
    | xml sel -T -t -v '//item/title'
}
