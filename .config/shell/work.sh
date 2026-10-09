# Work helpers. Nothing here names internal systems: hostnames, internal URLs and the
# like live in work.local.sh, which is yadm-encrypted (see ~/.config/yadm/encrypt).

# --- devbox helpers ---
if [ "$DOTFILES_OS" = Darwin ]; then
  # The devbox host comes from $DEV, set in work.local.sh
  _dev() { [ -n "${DEV-}" ] || { echo "DEV isn't set (put it in ~/.config/shell/work.local.sh)" >&2; return 1; }; }
  # Remote paths: the Mac's shell turns an unquoted ~ into /Users/jason before these functions
  # see it, so map "$HOME/..." back to a path relative to the remote home.
  _remote_path() { case $1 in "$HOME") ;; "$HOME"/*) printf '%s' "${1#"$HOME"/}" ;; *) printf '%s' "$1" ;; esac; }
  # dev   ssh to the devbox
  dev() { _dev && ssh "$DEV" "$@"; }
  # hd   herdr on the devbox
  hd() { _dev && herdr --remote "$DEV" "$@"; }
  # tun 8888 [host] [remote_port]   forward localhost:8888 to the devbox
  tun() { [ -n "${2-}" ] || _dev || return; ssh -N -L "${1}:localhost:${3:-$1}" "${2:-$DEV}"; }
  # pull <remote path> [host] [dest]   copy from the devbox (~/x works)
  pull() { [ -n "${2-}" ] || _dev || return; scp "${2:-$DEV}:$(_remote_path "$1")" "${3:-.}"; }
  # push <file> [remote dir] [host]   copy to the devbox (default: its home)
  push() { [ -n "${3-}" ] || _dev || return; scp "$1" "${3:-$DEV}:$(_remote_path "${2-}")"; }
fi
