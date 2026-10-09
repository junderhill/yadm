# DDG-specific helpers. Sourced only if this file exists.

DEV=${DEV-}   # set in work.local.sh

if [ "$(uname -s)" = Darwin ]; then
  alias dev="ssh $DEV"
  alias hd="herdr --remote $DEV"
  # tun 8888 [host] [remote_port]   forward localhost:8888 to the devbox
  tun() { ssh -N -L "$1:localhost:${3:-$1}" "${2:-$DEV}"; }
  # pull '/mnt/ebs/out/*.csv' [host] [dest]   copy from the devbox
  pull() { scp "${2:-$DEV}:$1" "${3:-.}"; }
  # push file [remote_dir] [host]   copy to the devbox
  push() { scp "$1" "${3:-$DEV}:${2:-~/}"; }
fi
