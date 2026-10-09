# Environment shared by zsh (Mac) and bash (devbox). Safe to source more than once.
# Load order: env.sh -> os/<os>.sh -> (shell rc) -> aliases.sh -> tools.sh -> work.sh/local.sh/secrets.sh

# Move/add a directory to the front (or back) of PATH, only if it exists. No subshells, so it's fast.
path_prepend() {
  [ -d "$1" ] || return 0
  PATH=":$PATH:"; PATH="${PATH//:$1:/:}"; PATH="${PATH#:}"; PATH="${PATH%:}"
  PATH="$1${PATH:+:$PATH}"
}
path_append() {
  [ -d "$1" ] || return 0
  PATH=":$PATH:"; PATH="${PATH//:$1:/:}"; PATH="${PATH#:}"; PATH="${PATH%:}"
  PATH="${PATH:+$PATH:}$1"
}

export EDITOR=nvim VISUAL=nvim PAGER=less LESS=-R

# Detected once and reused (override with DOTFILES_OS=Linux to test the Linux path elsewhere)
export DOTFILES_OS="${DOTFILES_OS:-$(uname -s)}"
case "$DOTFILES_OS" in
  Darwin) [ -f ~/.config/shell/os/darwin.sh ] && . ~/.config/shell/os/darwin.sh ;;
  Linux)  [ -f ~/.config/shell/os/linux.sh ]  && . ~/.config/shell/os/linux.sh ;;
esac

# Highest priority last
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/.local/bin"   # pipx, uv tools, claude, codebase-memory-mcp

export PATH
