# Hooks for interactive tools, shared by zsh and bash. Every tool is optional:
# a missing binary is skipped, never installed from here (that's the bootstrap's job).
if [ -n "$ZSH_VERSION" ]; then _sh=zsh; else _sh=bash; fi
_have() { command -v "$1" >/dev/null 2>&1; }

# Language versions, first match wins:
#  1. Chef boxes: pyenv/nodenv/goenv shims are already on PATH, so add nothing
#  2. mise, if installed: one tool for node/python/go (the personal-Linux equivalent of Chef's shims)
#  3. nvm, loaded lazily: put the default node on PATH, load nvm.sh (~300ms) only when `nvm` runs
export NVM_DIR="$HOME/.nvm"
if _have nodenv || _have pyenv || _have goenv; then
  :
elif _have mise; then
  eval "$(mise activate "$_sh")"
elif [ -s "$NVM_DIR/nvm.sh" ]; then
  _nvm_default=$(cat "$NVM_DIR/alias/default" 2>/dev/null)
  path_prepend "$NVM_DIR/versions/node/v${_nvm_default#v}/bin"
  nvm() { unset -f nvm; . "$NVM_DIR/nvm.sh"; nvm "$@"; }
  unset _nvm_default
fi

# zoxide replaces `cd`: works as normal, plus `cd foo` jumps to the best match, `cdi` picks interactively
_have zoxide && eval "$(zoxide init "$_sh" --cmd cd)"

# direnv: per-project .envrc (skip if Chef has already hooked it)
if _have direnv; then
  case "${PROMPT_COMMAND:-}${precmd_functions[*]:-}" in
    *_direnv_hook*) ;;
    *) eval "$(direnv hook "$_sh")" ;;
  esac
fi

# fzf: Ctrl-T inserts a file path, Alt-C cds into a subdir. Its Ctrl-R is disabled; McFly owns that.
if _have fzf; then
  FZF_CTRL_R_COMMAND=
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  _have fd && export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git' FZF_CTRL_T_COMMAND='fd --type f --hidden --exclude .git'
  eval "$(fzf --"$_sh" 2>/dev/null)"
fi

# McFly: Ctrl-R history search, ranked by directory, recency and exit status
if _have mcfly; then
  export MCFLY_KEY_SCHEME=vim MCFLY_FUZZY=2 MCFLY_RESULTS=30 MCFLY_PROMPT='❯'
  eval "$(mcfly init "$_sh")"
fi

# Starship prompt (config: ~/.config/starship.toml)
_have starship && eval "$(starship init "$_sh")"

unset _sh
