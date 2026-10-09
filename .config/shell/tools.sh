# Hooks for interactive tools, shared by zsh and bash. Every tool is optional:
# a missing binary is skipped, never installed from here (that's the bootstrap's job).
#
# On Chef boxes, Chef's ~/.bashrc runs MORE setup *after* ~/.ddg/bashrc (which loads this):
# `direnv hook bash`, `pyenv init -`, `pyenv virtualenv-init -`. So nothing here can detect
# those hooks; Chef-specific handling is keyed off DOTFILES_CHEF (set in os/linux.sh).
if [ -n "$ZSH_VERSION" ]; then _sh=zsh; else _sh=bash; fi
_have() { command -v "$1" >/dev/null 2>&1; }

# --- language versions --------------------------------------------------------------
# Python/Go: Chef's /opt/pyenv (or the system) on the devbox; Homebrew/uv elsewhere.
# Node, first match wins:
#  1. nodenv or fnm already present: leave it alone
#  2. mise (personal Linux): handles node, python, go
#  3. nvm, loaded lazily: put a node on PATH now, load nvm.sh (~300ms) only when `nvm` runs
export NVM_DIR="$HOME/.nvm"
if _have nodenv || _have fnm; then
  :
elif _have mise && [ -z "${DOTFILES_CHEF-}" ]; then
  eval "$(mise activate "$_sh")"
elif [ -s "$NVM_DIR/nvm.sh" ]; then
  # nvm's default alias may be exact (22.20.0), partial (22), lts/* or missing:
  # use the exact version if installed, else the newest match, else the newest installed
  _nvm_v=$(cat "$NVM_DIR/alias/default" 2>/dev/null); _nvm_v=${_nvm_v#v}
  _nvm_dir="$NVM_DIR/versions/node/v$_nvm_v"
  if [ -z "$_nvm_v" ] || [ ! -d "$_nvm_dir" ]; then
    _nvm_dir=$(ls -d "$NVM_DIR/versions/node/v$_nvm_v"* 2>/dev/null | sort -V | tail -n 1)
    [ -n "$_nvm_dir" ] || _nvm_dir=$(ls -d "$NVM_DIR"/versions/node/v* 2>/dev/null | sort -V | tail -n 1)
  fi
  [ -n "$_nvm_dir" ] && path_prepend "$_nvm_dir/bin"
  nvm() { unset -f nvm; . "$NVM_DIR/nvm.sh"; nvm "$@"; }
  unset _nvm_v _nvm_dir
fi

# --- navigation and environment -----------------------------------------------------
# zoxide replaces `cd`: works as normal, plus `cd foo` jumps to the best match, `cdi` picks interactively
_have zoxide && eval "$(zoxide init "$_sh" --cmd cd)"

# direnv: per-project .envrc. Chef hooks it itself (after this file), so only hook it elsewhere.
if _have direnv && [ -z "${DOTFILES_CHEF-}" ]; then
  case "${PROMPT_COMMAND:-}${precmd_functions[*]:-}" in
    *_direnv_hook*) ;;
    *) eval "$(direnv hook "$_sh")" ;;
  esac
fi

# fzf: Ctrl-T inserts a file path, Alt-C cds into a subdir. Its Ctrl-R is disabled; McFly owns that.
if _have fzf; then
  FZF_CTRL_R_COMMAND=
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  # fzf runs this through `sh -c`, which can't see aliases (Ubuntu's fd is `fdfind`, often aliased to fd),
  # so use whichever real binary exists. `command -v` prints a path only for real commands.
  for _fd in fd fdfind; do
    case "$(command -v "$_fd" 2>/dev/null)" in
      /*) export FZF_DEFAULT_COMMAND="$_fd --type f --hidden --exclude .git"
          export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"; break ;;
    esac
  done; unset _fd
  eval "$(fzf --"$_sh" 2>/dev/null)"
fi

# McFly: Ctrl-R history search, ranked by directory, recency and exit status
if _have mcfly; then
  export MCFLY_KEY_SCHEME=vim MCFLY_FUZZY=2 MCFLY_RESULTS=30 MCFLY_PROMPT='❯'
  eval "$(mcfly init "$_sh")"
fi

# --- prompt ---------------------------------------------------------------------------
# Starship (config: ~/.config/starship.toml). It moves earlier PROMPT_COMMAND hooks
# (auto-ls, McFly, zoxide) into STARSHIP_PROMPT_COMMAND and runs them itself.
_have starship && eval "$(starship init "$_sh")"

# Chef boxes: Chef's later direnv and pyenv-virtualenv inits would *prepend* their hooks,
# so they'd run before starship_precmd and overwrite $? (wrong error colour in the prompt).
# Put them after starship_precmd now. Both inits skip prepending when they find their hook
# name already there. The no-op stubs cover a hook whose tool isn't installed; Chef's real
# definitions replace them.
if [ "$_sh" = bash ] && [ -n "${DOTFILES_CHEF-}" ] && declare -F starship_precmd >/dev/null; then
  declare -F _direnv_hook >/dev/null || _direnv_hook() { :; }
  declare -F _pyenv_virtualenv_hook >/dev/null || _pyenv_virtualenv_hook() { :; }
  PROMPT_COMMAND="starship_precmd;_direnv_hook;_pyenv_virtualenv_hook"
fi

unset _sh
