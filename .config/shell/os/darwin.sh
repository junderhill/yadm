# macOS-only environment. Sourced by env.sh.

# Homebrew (static equivalent of `brew shellenv`, without spawning brew)
export HOMEBREW_PREFIX=/opt/homebrew HOMEBREW_CELLAR=/opt/homebrew/Cellar HOMEBREW_REPOSITORY=/opt/homebrew
path_prepend /opt/homebrew/sbin
path_prepend /opt/homebrew/bin
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

path_prepend /opt/homebrew/opt/libpq/bin                  # psql, pg_dump
path_prepend /opt/homebrew/opt/gawk/libexec/gnubin        # `awk` = GNU awk, same as Linux
path_prepend /opt/homebrew/opt/python@3.11/libexec/bin    # `python`/`pip` = Homebrew 3.11

export GOPATH="$HOME/Code/go" GOBIN="$HOME/Code/go/bin"
path_prepend "$GOBIN"

path_prepend "$HOME/Packages/bin"      # duplicacy (backups)
path_append  "$HOME/.lmstudio/bin"     # LM Studio CLI (lms)

export CLICOLOR=1                      # coloured BSD ls
export COPYFILE_DISABLE=1              # tar (and so `yadm encrypt`) won't add ._ AppleDouble files
