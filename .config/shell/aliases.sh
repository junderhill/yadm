# Aliases and functions shared by zsh and bash on every machine.
# `_alias_default name=value` only defines an alias if it doesn't exist yet, so the
# Chef-provided versions on the devbox win there. Elsewhere these definitions fill
# in, and the same names work the same way on every machine.
_alias_default() { alias "${1%%=*}" >/dev/null 2>&1 || alias "$1"; }

# --- navigation (cd itself is zoxide: `cd foo` jumps to your most-used dir matching "foo") ---
alias ..='cd ..' ...='cd ../..' ....='cd ../../..'
mkcd() { mkdir -p "$1" && cd "$1"; }    # make a dir and cd into it
_alias_default ll='ls -alF'      # same as Chef's
_alias_default la='ls -A'
_alias_default l='ls -CF'
if [ "$DOTFILES_OS" = Linux ]; then           # macOS gets colour from CLICOLOR instead
  _alias_default ls='ls --color=auto'
  _alias_default grep='grep --color=auto'
fi
# Falcon vault: ~/falcon-vault on every machine (symlink to ~/SyncThing/Falcon-Vault where that's the real copy)
if [ -d ~/falcon-vault ]; then alias vault='cd ~/falcon-vault' work='cd ~/falcon-vault/01-Work'; fi
alias dum='du -h -d 1 | sort -h'      # dir sizes, biggest last

# --- devbox (Chef) aliases, available everywhere ---
# Copied from Chef's ~/.ddg_aliases (2026-10-09); on the devbox Chef's own definitions win.
_alias_default tn='tmux new -s'
_alias_default ta='tmux a -t'
_alias_default j='jobs'
_alias_default cp='/bin/cp -v'
_alias_default mv='/bin/mv -v'
_alias_default rm='/bin/rm -v'
_alias_default ln='/bin/ln -v'

# --- editors / tools ---
alias vim=nvim v=nvim
command -v lazygit >/dev/null 2>&1 && alias lg=lazygit
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
_alias_default gs='git log -p --stat --color'
_alias_default fix='git commit --amend -C HEAD'
_alias_default ff='git merge --ff-only'
# print the repo's main branch name (main/master)
git_main_branch() {
  local b
  b=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null) && { echo "${b#origin/}"; return; }
  git show-ref --verify --quiet refs/heads/main && echo main || echo master
}
gm() { git checkout "$(git_main_branch)" && git pull; }    # back to main, up to date

# --- GitHub ---
# gh_comments <owner/repo> <pr> [user]   PR review comments (humans only) as JSON
gh_comments() {
  if [ -z "${1-}" ] || [ -z "${2-}" ]; then
    echo "usage: gh_comments <owner/repo> <pr_number> [user]" >&2; return 1
  fi
  # --paginate: gh returns 30 per page; -s + add merges the pages into one array
  gh api --paginate "repos/$1/pulls/$2/comments" |
    jq -s --arg user "${3-}" '[ add[] | select(.user.type == "User" and ($user == "" or .user.login == $user))
                               | { user: .user.login, diff_hunk, line, start_line, body } ]'
}

# --- Claude Code ---
alias cl=claude cr='claude --resume' ca='claude agents'
fresh() { gm && claude "$@"; }    # start a task: update main, open Claude

# --- keys & tricks ---
#: cd foo  jump to the best-matching dir you've visited (zoxide)
#: cdi  pick a dir interactively (zoxide + fzf)
#: Ctrl-R  search history, ranked by dir and recency (McFly)
#: Ctrl-T  insert a file path (fzf)
#: Alt-C  cd into a subdir (fzf)
#: Esc v  edit the current command in nvim
#: ↑ / ↓  history matching what you've typed
#: Ctrl-L  clear screen
#: ahelp [word]  this cheat sheet, optionally filtered

# Cheat sheet built from the comments in these files, with live values from this shell
ahelp() {
  local f k n d v hdr="" pat="${1-}" B="" D="" H="" R=""
  [ -t 1 ] && B=$(printf '\033[1m') D=$(printf '\033[2m') H=$(printf '\033[1;35m') R=$(printf '\033[0m')
  for f in ~/.config/shell/aliases.sh ~/.config/shell/work.sh ~/.config/shell/work.local.sh ~/.config/shell/local.sh; do
    [ -f "$f" ] && cat "$f"
  done | awk -f ~/.config/shell/ahelp.awk | while IFS='|' read -r k n d; do
    case $k in
      S) hdr=$n; continue ;;
      A) v=$(alias "$n" 2>/dev/null) || continue
         v=${v#alias }; v=${v#*=}; v=${v#\'}; v=${v%\'} ;;
      F) type "$n" >/dev/null 2>&1 || continue; v="ƒ" ;;
      K) v="" ;;
    esac
    if [ -n "$pat" ]; then
      printf '%s %s %s %s\n' "$hdr" "$n" "$v" "$d" | grep -qi -- "$pat" || continue
    fi
    [ -n "$hdr" ] && { printf '\n%s%s%s\n' "$H" "$hdr" "$R"; hdr=""; }
    if [ "$k" = K ]; then
      printf '  %s%-15s%s %s\n' "$B" "$n" "$R" "$d"
    elif [ "$k" = F ]; then
      printf '  %s%-15s%s %s\n' "$B" "$n" "$R" "$d"
    else
      [ ${#v} -gt 43 ] && v="${v:0:42}…"
      printf '  %s%-15s%s %-43s %s%s%s\n' "$B" "$n" "$R" "$v" "$D" "$d" "$R"
    fi
  done
  echo
}
