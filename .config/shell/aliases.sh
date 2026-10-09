# Aliases and functions shared by zsh and bash on every machine.
# `_alias_default name=value` only defines an alias if it doesn't exist yet, so the
# Chef-provided versions on the devbox win there. Elsewhere these definitions fill
# in, and the same names work the same way on every machine.
_alias_default() { alias "${1%%=*}" >/dev/null 2>&1 || alias "$1"; }

# --- navigation (cd itself is zoxide: `cd foo` jumps to your most-used dir matching "foo") ---
alias ..='cd ..' ...='cd ../..' ....='cd ../../..'
mkcd() { mkdir -p "$1" && cd "$1"; }
_alias_default ll='ls -lh'
_alias_default la='ls -lAh'
_alias_default l='ls -lah'
if [ "$DOTFILES_OS" = Linux ]; then           # macOS gets colour from CLICOLOR instead
  _alias_default ls='ls --color=auto'
  _alias_default grep='grep --color=auto'
fi
# Falcon vault: ~/falcon-vault on every machine (symlink to ~/SyncThing/Falcon-Vault where that's the real copy)
if [ -d ~/falcon-vault ]; then alias vault='cd ~/falcon-vault' work='cd ~/falcon-vault/01-Work'; fi
alias dum='du -h -d 1 | sort -h'      # dir sizes, biggest last

# --- same as the Chef aliases on the devbox (approximations; the devbox's own definitions win there) ---
_alias_default tn='tmux new -s'
_alias_default ta='tmux attach -t'
_alias_default j='jobs'
_alias_default cp='cp -v'
_alias_default mv='mv -v'
_alias_default rm='rm -v'
_alias_default ln='ln -v'

# --- editors / tools ---
alias vim=nvim v=nvim
alias lg=lazygit
alias mdv='glow -p'
alias dotsync='yadm pull && yadm bootstrap'   # Chef boxes also pull on every shell start

# --- git (status/diff/pull/push are the most-typed commands on both machines) ---
alias g=git
alias gst='git status' gd='git diff' gds='git diff --staged'
alias ga='git add' gaa='git add -A'
alias gco='git checkout' gcb='git checkout -b' gsw='git switch'
alias gl='git pull' gp='git push'
alias glog='git log --oneline --graph --decorate -20'
_alias_default gc='git commit -a'
_alias_default gs='git log -p --stat'
_alias_default fix='git commit -a --amend --no-edit'
_alias_default ff='git merge --ff-only'
git_main_branch() {
  local b
  b=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null) && { echo "${b#origin/}"; return; }
  git show-ref --verify --quiet refs/heads/main && echo main || echo master
}
gm() { git checkout "$(git_main_branch)" && git pull; }    # back to main, up to date

# --- Claude Code ---
alias cl=claude cr='claude --resume' ca='claude agents'
fresh() { gm && claude "$@"; }    # start a task: update main, open Claude
