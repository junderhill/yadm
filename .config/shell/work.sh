# DDG-specific helpers. Sourced only if this file exists.


# --- devbox helpers ---
DEV=${DEV-}   # set in work.local.sh

if [ "$DOTFILES_OS" = Darwin ]; then
  alias dev="ssh $DEV"
  alias hd="herdr --remote $DEV"
  # Remote paths: the Mac's shell turns an unquoted ~ into /Users/jason before these functions
  # see it, so map "$HOME/..." back to a path relative to the remote home (/home/junderhill).
  _remote_path() { case $1 in "$HOME") ;; "$HOME"/*) printf '%s' "${1#"$HOME"/}" ;; *) printf '%s' "$1" ;; esac; }
  # tun 8888 [host] [remote_port]   forward localhost:8888 to the devbox
  tun() { ssh -N -L "$1:localhost:${3:-$1}" "${2:-$DEV}"; }
  # pull <remote path> [host] [dest]   copy from the devbox (~/x works)
  pull() { scp "${2:-$DEV}:$(_remote_path "$1")" "${3:-.}"; }
  # push <file> [remote dir] [host]   copy to the devbox (default: its home)
  push() { scp "$1" "${3:-$DEV}:$(_remote_path "${2-}")"; }
fi
