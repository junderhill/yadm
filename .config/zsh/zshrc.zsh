# Interactive zsh (Mac). Replaces oh-my-zsh. Shared config lives in ~/.config/shell.

source ~/.config/shell/env.sh

# --- history (McFly keeps its own ranked DB, but reads new commands from here) ---
HISTFILE=~/.zsh_history HISTSIZE=100000 SAVEHIST=100000
setopt EXTENDED_HISTORY INC_APPEND_HISTORY HIST_IGNORE_SPACE HIST_IGNORE_DUPS HIST_REDUCE_BLANKS HIST_VERIFY
setopt INTERACTIVE_COMMENTS AUTO_PUSHD PUSHD_IGNORE_DUPS NO_BEEP

# --- vi mode ---
bindkey -v
KEYTIMEOUT=1
bindkey -M viins '^?' backward-delete-char '^H' backward-delete-char '^W' backward-kill-word \
  '^U' backward-kill-line '^A' beginning-of-line '^E' end-of-line
autoload -Uz edit-command-line && zle -N edit-command-line
bindkey -M vicmd v edit-command-line               # Esc v: edit the command in nvim
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search && zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search '^[[B' down-line-or-beginning-search   # ↑/↓ match typed prefix
bindkey -M vicmd k up-line-or-beginning-search j down-line-or-beginning-search
# Cursor: bar in insert mode, block in normal mode
_vi_cursor() { [[ $KEYMAP == vicmd ]] && printf '\e[2 q' || printf '\e[6 q'; }
zle-keymap-select() { _vi_cursor }; zle-line-init() { _vi_cursor }
zle -N zle-keymap-select && zle -N zle-line-init

# --- completion (full rebuild at most once a day) ---
[[ -n $HOMEBREW_PREFIX ]] && fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)
autoload -Uz compinit
() { setopt local_options extended_glob; if [[ -n ~/.zcompdump(#qN.mh+24) || ! -f ~/.zcompdump ]]; then compinit; else compinit -C; fi }
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors ''

# --- list the directory after every cd (interactive terminals only) ---
autoload -Uz add-zsh-hook
_auto_ls() { [[ -o interactive && -t 1 ]] && ls }
add-zsh-hook chpwd _auto_ls

# --- shared aliases, tools, machine extras ---
source ~/.config/shell/aliases.sh
source ~/.config/shell/tools.sh
bindkey -M vicmd '^R' mcfly-history-widget 2>/dev/null   # Ctrl-R works in normal mode too
for f in ~/.config/shell/{work,local,secrets}.sh(N); do source $f; done; unset f

# --- plugins (syntax highlighting must be last) ---
for p in zsh-autosuggestions zsh-syntax-highlighting; do
  for d in ${HOMEBREW_PREFIX:-/nonexistent}/share/$p /usr/share/$p /usr/share/zsh/plugins/$p; do
    [[ -r $d/$p.zsh ]] && { source $d/$p.zsh; break; }
  done
done; unset p d
