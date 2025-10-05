# Path to your oh-my-zsh installation.
export ZSH=/Users/jason/.oh-my-zsh
export GOPATH=/Users/$USER/Code/go
export GOBIN=$GOPATH/bin
export PATH=$GOBIN:$PATH
export PATH="$HOME/.plenv/bin:$PATH"
export PATH="$HOME/Packages/bin:$PATH"
export PATH="/opt/homebrew/opt/python@3.11/libexec/bin:$PATH"
export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"

# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="dracula"

eval $(thefuck --alias)
source $ZSH/oh-my-zsh.sh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

#Enable vi mode
bindkey -v
bindkey '^R' history-incremental-search-backward

plugins=(
  git
  docker
  tmux
  vi-mode
  thefuck
  history 
  history-substring-search 
  brew
  zsh-syntax-highlighting
  zsh-history-substring-search
  z
)

# Created by `pipx` on 2024-01-20 08:50:35
export PATH="$PATH:/Users/jason/.local/bin"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(zoxide init zsh)"

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
