# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="fishy"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git perl)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=$PATH:/home/$USER/bin/:/home/$USER/.cabal/bin/

unsetopt correct_all

export PERL_LOCAL_LIB_ROOT="/home/djanatyn/perl5";
export PERL_MB_OPT="--install_base /home/djanatyn/perl5";
export PERL_MM_OPT="INSTALL_BASE=/home/djanatyn/perl5";
export PERL5LIB="/home/djanatyn/perl5/lib/perl5/i486-linux-gnu-thread-multi-64int:/home/djanatyn/perl5/lib/perl5";
export PATH="/home/djanatyn/perl5/bin:$PATH";
# export TERM=xterm

# my aliases
alias p=perl
alias sprunge="curl -F 'sprunge=<-' http://sprunge.us"
alias r="rsync -rvzP"

# my functions!
unzip-all-files() { for zipfile in *.zip; do unzip $zipfile -d "$(echo $zipfile | sed s/\.zip$//)"; rm $zipfile; done }
