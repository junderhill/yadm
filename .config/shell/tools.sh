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

# Bash hook order. starship_precmd saves $?, restores it, runs STARSHIP_PROMPT_COMMAND,
# *then* builds PS1, and leaves $? clobbered afterwards. So every other prompt hook belongs
# in STARSHIP_PROMPT_COMMAND: it sees the real exit status, and env changes (direnv) show
# in the same prompt.
if [ "$_sh" = bash ] && declare -F starship_precmd >/dev/null; then
  # Chef boxes: Chef's direnv and pyenv-virtualenv inits run *after* this file and would
  # prepend their hooks ahead of starship_precmd (bad $?, env shown one prompt late).
  # Run them from STARSHIP_PROMPT_COMMAND, and name them in a comment line in
  # PROMPT_COMMAND so Chef's inits think they're already installed. The `;name;` form
  # satisfies both direnv's newer `*";_direnv_hook;"*` check and the older regex check.
  # The no-op stubs cover a tool that isn't installed; Chef's real definitions replace them.
  if [ -n "${DOTFILES_CHEF-}" ]; then
    declare -F _direnv_hook >/dev/null || _direnv_hook() { :; }
    declare -F _pyenv_virtualenv_hook >/dev/null || _pyenv_virtualenv_hook() { :; }
    STARSHIP_PROMPT_COMMAND="_direnv_hook;_pyenv_virtualenv_hook${STARSHIP_PROMPT_COMMAND:+;$STARSHIP_PROMPT_COMMAND}"
    PROMPT_COMMAND=$'starship_precmd\n#;_direnv_hook;_pyenv_virtualenv_hook; (run from STARSHIP_PROMPT_COMMAND)'
  fi
  # McFly (bash >= 5.1) registers itself as a separate PROMPT_COMMAND[n] entry, which runs
  # after starship_precmd and so records every command's exit status as 0. Move it into
  # STARSHIP_PROMPT_COMMAND, first, where $? is the real status.
  if declare -F mcfly_prompt_command >/dev/null; then
    if [[ "$(declare -p PROMPT_COMMAND 2>/dev/null)" == "declare -a"* ]]; then
      _pc=(); for _c in "${PROMPT_COMMAND[@]}"; do [ "$_c" = mcfly_prompt_command ] || _pc+=("$_c"); done
      PROMPT_COMMAND=("${_pc[@]}"); unset _pc _c
    fi
    case ";${STARSHIP_PROMPT_COMMAND-};" in
      *";mcfly_prompt_command;"*) ;;
      *) STARSHIP_PROMPT_COMMAND="mcfly_prompt_command${STARSHIP_PROMPT_COMMAND:+;$STARSHIP_PROMPT_COMMAND}" ;;
    esac
  fi
  # Starship restores $? but then runs `[[ -n $STARSHIP_PROMPT_COMMAND ]]`, which resets it
  # to 0 before the eval. Put the saved status back first so the hooks really see it.
  _restore_status() { return "${STARSHIP_CMD_STATUS:-0}"; }
  STARSHIP_PROMPT_COMMAND="_restore_status${STARSHIP_PROMPT_COMMAND:+;$STARSHIP_PROMPT_COMMAND}"
fi

unset _sh
