# Interactive bash. On the DDG devbox Chef owns ~/.bashrc, so this is sourced from
# ~/.ddg/bashrc (which Chef's ~/.bashrc sources last). vi mode etc. live in ~/.inputrc.
case $- in *i*) ;; *) return ;; esac

. ~/.config/shell/env.sh

# --- history (McFly keeps its own ranked DB, but reads new commands from here) ---
HISTFILE=${HISTFILE:-$HOME/.bash_history}; [ -f "$HISTFILE" ] || : > "$HISTFILE"   # McFly needs it to exist
HISTCONTROL=ignoreboth HISTSIZE=100000 HISTFILESIZE=200000 HISTTIMEFORMAT='%F %T '
shopt -s histappend checkwinsize cmdhist

# --- completion, unless Chef / Ubuntu's stock .bashrc already loaded it ---
if [ -z "${BASH_COMPLETION_VERSINFO-}" ]; then
  for f in "${HOMEBREW_PREFIX:-/nonexistent}/etc/profile.d/bash_completion.sh" /usr/share/bash-completion/bash_completion /etc/bash_completion; do
    [ -r "$f" ] && { . "$f"; break; }
  done
fi

# --- list the directory after every cd ---
_auto_ls() { [ "$PWD" != "${_last_pwd:-$PWD}" ] && [ -t 1 ] && ls; _last_pwd=$PWD; }
PROMPT_COMMAND="_auto_ls${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# --- shared aliases, tools, machine extras ---
. ~/.config/shell/aliases.sh
. ~/.config/shell/tools.sh
# ~/.bash_secrets: the devbox's pre-existing secrets file (move into secrets.sh after migrating)
for f in ~/.config/shell/work.sh ~/.config/shell/local.sh ~/.config/shell/secrets.sh ~/.bash_secrets; do
  [ -f "$f" ] && . "$f"
done; unset f
